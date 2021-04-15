/*
   WiP
*/

#include "KeyBuffer.h"

int OCTAVE_RANGE = 6;

int octaveRangePin = A0;
int speakerPin = 12;

float notes[] = {174.61, 185.00, 196.00, 207.65, 220.00, 233.08, 246.94, 261.63, 277.18, 293.66, 311.13, 329.63, 349.23, 369.99, 392.00, 415.30, 440.00, 466.16, 493.88, 523.25};

KeyBuffer buffer;

int octave;

unsigned long updateThrottle = 100;
unsigned long previousMillis = 0;

void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);

  Serial.println("---------");
}

float getFrequency() {
  return notes[buffer.getFirst()] / 2 * octave;
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
