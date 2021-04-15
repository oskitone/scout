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

long octaveThrottle = 200;
long frequencyThrottle = 24; // max

float glideStep = 10; // TODO: pot control like octave
float frequency = 0;

void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);
}

float getFrequency(long key) {
  return notes[key] / 2 * octave;
}

float getTargetFrequency() {
  return getFrequency(buffer.getFirst());
}

unsigned long frequencyPreviousMillis = 0;
void updateFrequency() {
  unsigned long currentMillis = millis();

  if (
    (frequency == 0) ||
    ((unsigned long)(currentMillis - frequencyPreviousMillis) >= frequencyThrottle)
  ) {
    float target = getTargetFrequency();

    if ((frequency == 0) || (glideStep == 0)) {
      frequency = target;
    } else if (frequency != target) {
      frequency = (target > frequency)
                  ? min(target, frequency + glideStep)
                  : max(target, frequency - glideStep);
    }

    frequencyPreviousMillis = millis();
  }
}

unsigned long octavePreviousMillis = 0;
void updateOctave() {
  unsigned long currentMillis = millis();

  if ((unsigned long)(currentMillis - octavePreviousMillis) >= octaveThrottle) {
    float voltage = analogRead(octaveRangePin) * (5.0 / 1023.0);
    octave = round(voltage / 5 * (OCTAVE_RANGE - 1)) + 1;

    octavePreviousMillis = millis();
  }
}

void loop() {
  buffer.populate();

  updateOctave();

  if (buffer.isEmpty()) {
    frequency = 0;

    noTone(speakerPin);
    digitalWrite(LED_BUILTIN, LOW);
  } else {
    updateFrequency();

    tone(speakerPin, frequency);
    digitalWrite(LED_BUILTIN, HIGH);

    Serial.println(
      "frequency: " + String(frequency)
      + "\ttarget: " + String(getTargetFrequency())
    );
  }
}
