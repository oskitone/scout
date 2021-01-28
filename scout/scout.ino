/*
   WiP
*/

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

void setup() {
  int KEYPAD_LIBRARY_MINIMUM_DEBOUNCE = 1;

  Serial.begin(9600);
  pinMode(octaveSwitchPin, INPUT_PULLUP);
  pinMode(LED_BUILTIN, OUTPUT);
  buttons.setDebounceTime(KEYPAD_LIBRARY_MINIMUM_DEBOUNCE);
}

void loop() {
  populateFrequencyAndIsActive();

  if (isActive) {
    Serial.println(String(frequency));
    tone(speakerPin, frequency);
    digitalWrite(LED_BUILTIN, HIGH);
  } else {
    noTone(speakerPin);
    digitalWrite(LED_BUILTIN, LOW);
  }
}
