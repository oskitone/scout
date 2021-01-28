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
int key_indexes[ROWS][COLS] = {
  {1, 5, 9, 13},
  {2, 6, 10, 14},
  {3, 7, 11, 15},
  {4, 8, 12, 16}
};
float notes[] = {130.75, 138.5, 146.75, 155.5, 164.75, 174.5, 185, 196, 207.75, 220, 233, 247, 261.75, 277.25, 293.75, 311.25};
byte rowPins[ROWS] = {6, 10, 11, 4};
byte colPins[COLS] = {8, 5, 3, 7};

Keypad buttons = Keypad( makeKeymap(key_indexes), rowPins, colPins, ROWS, COLS );

float frequency = 0;
int octave = 0;
bool isActive = false;

void populateFrequencyAndIsActive() {
  isActive = false;

  buttons.getKeys(); // populate keys

  for (int i = 0; i < LIST_MAX; i++) {
    byte kstate = buttons.key[i].kstate;
    byte kchar = buttons.key[i].kchar - 1;

    if (kstate == PRESSED || kstate == HOLD) {
      octave = (digitalRead(octaveSwitchPin) == LOW) + 1;
      frequency = notes[kchar] * octave;
      isActive = true;
    }
  }
}

CircularBuffer<int, 4> buffer;

void printBuffer() {
  if (buffer.isEmpty()) {
//    Serial.println("empty");
  } else {
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

bool isPressed(char c) {
  bool value = false;

  if (!buffer.isEmpty()) {
    for (decltype(buffer)::index_t i = 0; i < buffer.size() - 1; i++) {
      if (c == buffer[i]) {
        value = true;
        break;
      }
    }

    return value;
  }
}

bool removeFromStack(char c) {
  char newStack[4 - 1] = {};
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
      buffer.push(newStack[i]);
    }
  }
}

void testBuffer(char c) {
  if (!isPressed(c)) {
    buffer.unshift(c);
  }
  printBuffer();
}

void setup() {
  int KEYPAD_LIBRARY_MINIMUM_DEBOUNCE = 1;

  Serial.begin(9600);
  pinMode(octaveSwitchPin, INPUT_PULLUP);
  pinMode(LED_BUILTIN, OUTPUT);
  buttons.setDebounceTime(KEYPAD_LIBRARY_MINIMUM_DEBOUNCE);

  Serial.println("---------");
  printBuffer();

  testBuffer(1);
  testBuffer(2);
  testBuffer(3);
  testBuffer(4);
  testBuffer(5);
  testBuffer(6);
  testBuffer(4);
  testBuffer(1);

  removeFromStack(1);
  printBuffer();

  removeFromStack(8);
  printBuffer();

  testBuffer(7);
}

void loop() {
  populateFrequencyAndIsActive();

  if (isActive) {
    //    Serial.println(String(frequency));
    tone(speakerPin, frequency);
    digitalWrite(LED_BUILTIN, HIGH);
  } else {
    noTone(speakerPin);
    digitalWrite(LED_BUILTIN, LOW);
  }
}
