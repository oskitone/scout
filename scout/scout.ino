/*
   WiP
*/

#include "KeyBuffer.h"

int OCTAVE_RANGE = 6;

int octaveRangePin = A0;
int speakerPin = 12;

float notes[] = {130.75, 138.5, 146.75, 155.5, 164.75, 174.5, 185, 196, 207.75, 220, 233, 247, 261.75, 277.25, 293.75, 311.25};

KeyBuffer buffer;

int octave;

unsigned long updateThrottle = 100;
unsigned long previousMillis = 0;

void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);

  Serial.println("---------");
}

int getOctave() {
  return octave;
}

float getFrequency() {
  return notes[buffer.getFirst()] / 2 * getOctave();
}

void updateOctave() {
  unsigned long currentMillis = millis();

  if ((unsigned long)(currentMillis - previousMillis) >= updateThrottle) {
    float voltage = analogRead(octaveRangePin) * (5.0 / 1023.0);
    octave = round(voltage / 5 * (OCTAVE_RANGE - 1)) + 1;
    Serial.println(octave);

    previousMillis = millis();
  }
}

void loop() {
  buffer.populate();
  updateOctave();

  if (buffer.isEmpty()) {
    noTone(speakerPin);
    digitalWrite(LED_BUILTIN, LOW);
  } else {
    tone(speakerPin, getFrequency());
    digitalWrite(LED_BUILTIN, HIGH);
  }

  buffer.print();
}
