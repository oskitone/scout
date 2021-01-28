/*
   WiP
*/

#include "KeyBuffer.h"

int octaveSwitchPin = 9;
int speakerPin = 12;

float notes[] = {130.75, 138.5, 146.75, 155.5, 164.75, 174.5, 185, 196, 207.75, 220, 233, 247, 261.75, 277.25, 293.75, 311.25};

KeyBuffer buffer;

void setup() {
  Serial.begin(9600);
  pinMode(octaveSwitchPin, INPUT_PULLUP);
  pinMode(LED_BUILTIN, OUTPUT);

  Serial.println("---------");
}

int getOctave() {
  return (digitalRead(octaveSwitchPin) == LOW) + 1;
}

float getFrequency() {
  return notes[buffer.getFirst()] * getOctave();
}

void loop() {
  buffer.populate();

  if (buffer.isEmpty()) {
    noTone(speakerPin);
    digitalWrite(LED_BUILTIN, LOW);
  } else {
    tone(speakerPin, getFrequency());
    digitalWrite(LED_BUILTIN, HIGH);
  }

  buffer.print();
}
