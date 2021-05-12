/*
  WiP
*/
#include "Arduino.h"
#include "KeyBuffer.h"

#define CIRCULAR_BUFFER_DEBUG
#include <CircularBuffer.h>
#include <Keypad.h>

const byte ROWS = 4;
const byte COLS = 5;
byte key_indexes[ROWS][COLS] = {
  {1, 5, 9, 12, 15},
  {2, 6, 10, 13, 16},
  {3, 7, 11, 14, 17},
  {4, 8}
};
byte rowPins[ROWS] = {7, 8, 9, 10};
byte colPins[COLS] = {2, 3, 4, 5, 6};

// TODO: move into constructor
Keypad _buttons = Keypad( makeKeymap(key_indexes), rowPins, colPins, ROWS, COLS );

KeyBuffer::KeyBuffer() {
  CircularBuffer<int, 4> _buffer;

  // TODO: confirm this runs in setup() OR it's okay if it doesn't
  int KEYPAD_LIBRARY_MINIMUM_DEBOUNCE = 1;
  _buttons.setDebounceTime(KEYPAD_LIBRARY_MINIMUM_DEBOUNCE);
}

// TODO: replace other versions?
bool KeyBuffer::isEmpty() {
  return _buffer.isEmpty();
}

bool KeyBuffer::isInBuffer(int c) {
  bool value = false;

  if (!_buffer.isEmpty()) {
    // TODO: duplicate issue may be from up here
    for (decltype(_buffer)::index_t i = 0; i < _buffer.size() - 1; i++) {
      if (c == _buffer[i]) {
        value = true;
        break;
      }
    }
  }

  return value;
}

bool KeyBuffer::removeFromBuffer(int c) {
  int newStack[4 - 1] = {};
  int newI = 0;

  bool hasRemoval = false;

  for (decltype(_buffer)::index_t i = 0; i < _buffer.size(); i++) { // why does - 1 leave out the last char?
    if (c != _buffer[i]) {
      newStack[newI++] = _buffer[i];
    } else {
      hasRemoval = true;
    }
  }

  if (hasRemoval) {
    _buffer.clear();

    for (int i = 0; i < 4 - 1; i++) {
      // TODO: pretty sure this is adding 0s when it runs out
      _buffer.push(newStack[i]);
    }
  }
}

void KeyBuffer::populate() {
  bool isActive = false;

  _buttons.getKeys(); // populate keys

  for (int i = 0; i < LIST_MAX; i++) {
    byte kstate = _buttons.key[i].kstate;
    byte kchar = _buttons.key[i].kchar - 1;

    if (kstate == PRESSED || kstate == HOLD) {
      // TODO: fix duplicates...
      if (!isInBuffer(kchar)) {
        _buffer.unshift(kchar);
      }

      isActive = true;
    } else if (isInBuffer(kchar)) {
      removeFromBuffer(kchar);
    }
  }

  if (!isActive) {
    _buffer.clear();
  }
}

void KeyBuffer::print() {
  if (!_buffer.isEmpty()) {
    Serial.print("[");
    for (decltype(_buffer)::index_t i = 0; i < _buffer.size() - 1; i++) {
      Serial.print(_buffer[i]);
      Serial.print(",");
    }
    Serial.print(_buffer[_buffer.size() - 1]);
    Serial.print("] (");

    Serial.print(_buffer.size());
    Serial.print("/");
    Serial.print(_buffer.size() + _buffer.available());
    if (_buffer.isFull()) {
      Serial.print(" full");
    }

    Serial.println(")");
  }
}

char KeyBuffer::getFirst() {
  return _buffer.first();
}
