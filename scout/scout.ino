/*
   WiP
*/

#define CIRCULAR_BUFFER_DEBUG
#include <CircularBuffer.h>
#include <Keypad.h>

int octaveSwitchPin = 9;
int speakerPin = 12;

const byte ROWS = 4;
const byte COLS = 4;
byte key_indexes[ROWS][COLS] = {
  {1, 5, 9, 13},
  {2, 6, 10, 14},
  {3, 7, 11, 15},
  {4, 8, 12, 16}
};
float notes[] = {130.75, 138.5, 146.75, 155.5, 164.75, 174.5, 185, 196, 207.75, 220, 233, 247, 261.75, 277.25, 293.75, 311.25};
byte rowPins[ROWS] = {6, 10, 11, 4};
byte colPins[COLS] = {8, 5, 3, 7};

Keypad buttons = Keypad( makeKeymap(key_indexes), rowPins, colPins, ROWS, COLS );

CircularBuffer<int, 4> buffer;

bool isInBuffer(int c) {
  bool value = false;

  if (!buffer.isEmpty()) {
    // TODO: duplicate issue may be from up here
    for (decltype(buffer)::index_t i = 0; i < buffer.size() - 1; i++) {
      if (c == buffer[i]) {
        value = true;
        break;
      }
    }
  }

  return value;
}

void populateBuffer() {
  bool isActive = false;

  buttons.getKeys(); // populate keys

  for (int i = 0; i < LIST_MAX; i++) {
    byte kstate = buttons.key[i].kstate;
    byte kchar = buttons.key[i].kchar - 1;

    if (kstate == PRESSED || kstate == HOLD) {
      // TODO: fix duplicates...
      if (!isInBuffer(kchar)) {
        buffer.unshift(kchar);
      }

      isActive = true;
    } else if (isInBuffer(kchar)) {
      removeFromBuffer(kchar);
    }
  }

  if (!isActive) {
    buffer.clear();
  }
}

void printBuffer() {
  if (!buffer.isEmpty()) {
    Serial.print("[");
    for (decltype(buffer)::index_t i = 0; i < buffer.size() - 1; i++) {
      Serial.print(buffer[i]);
      Serial.print(",");
    }
    Serial.print(buffer[buffer.size() - 1]);
    Serial.print("] (");

    Serial.print(buffer.size());
    Serial.print("/");
    Serial.print(buffer.size() + buffer.available());
    if (buffer.isFull()) {
      Serial.print(" full");
    }

    Serial.println(")");
  }
}

bool removeFromBuffer(int c) {
  int newStack[4 - 1] = {};
  int newI = 0;

  bool hasRemoval = false;

  for (decltype(buffer)::index_t i = 0; i < buffer.size(); i++) { // why does - 1 leave out the last char?
    if (c != buffer[i]) {
      newStack[newI++] = buffer[i];
    } else {
      hasRemoval = true;
    }
  }

  if (hasRemoval) {
    buffer.clear();

    for (int i = 0; i < 4 - 1; i++) {
      // TODO: pretty sure this is adding 0s when it runs out
      buffer.push(newStack[i]);
    }
  }
}

void setup() {
  int KEYPAD_LIBRARY_MINIMUM_DEBOUNCE = 1;

  Serial.begin(9600);
  pinMode(octaveSwitchPin, INPUT_PULLUP);
  pinMode(LED_BUILTIN, OUTPUT);
  buttons.setDebounceTime(KEYPAD_LIBRARY_MINIMUM_DEBOUNCE);

  Serial.println("---------");
}

int getOctave() {
  return (digitalRead(octaveSwitchPin) == LOW) + 1;
}

float getFrequency() {
  return notes[buffer.first()] * getOctave();
}

void loop() {
  populateBuffer();

  if (buffer.isEmpty()) {
    noTone(speakerPin);
    digitalWrite(LED_BUILTIN, LOW);
  } else {
    tone(speakerPin, getFrequency());
    digitalWrite(LED_BUILTIN, HIGH);
  }

  printBuffer();
}
