/*
   WiP
*/

#include "KeyBuffer.h"

bool printToSerial = false;

int OCTAVE = 3;
float GLIDE = .25;

int CYCLES_PER_GLIDE_MAX = printToSerial ? 25 : 250;

int speakerPin = 11;

float notes[] = {
    261.63, // C4
    277.18, // C#4/Db4
    293.66, // D4
    311.13, // D#4/Eb4
    329.63, // E4
    349.23, // F4
    369.99, // F#4/Gb4
    392.00, // G4
    415.30, // G#4/Ab4
    440.00, // A4
    466.16, // A#4/Bb4
    493.88, // B4
    523.25, // C5
    554.37, // C#5/Db5
    587.33, // D5
    622.25, // D#5/Eb5
    659.25, // E5
};

KeyBuffer buffer;

float frequency = 0;
float glideStep;

float getFrequency(long key) {
  return notes[key] / 4 * pow(2, OCTAVE);
}

float getTargetFrequency() {
  return getFrequency(buffer.getFirst());
}

float previousTargetFrequency;
void updateFrequency() {
  float target = getTargetFrequency();
  bool needsUpdate = frequency != target;

  if (needsUpdate) {
    if ((frequency == 0) || (GLIDE == 0)) {
      frequency = target;
    } else {
      if (target != previousTargetFrequency) {
        glideStep = abs(target - previousTargetFrequency)
          / (GLIDE * CYCLES_PER_GLIDE_MAX);
      }

      frequency = (target > frequency)
        ? min(target, frequency + glideStep)
        : max(target, frequency - glideStep);
      }
  }

  if (!needsUpdate) {
    previousTargetFrequency = target;
  }
}

void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  buffer.populate();

  if (printToSerial) {
    Serial.println(
      "frequency:" + String(frequency)
      + ",target:" + String(getTargetFrequency())
      + ",previousTargetFrequency:" + String(previousTargetFrequency)
    );
  }

  if (buffer.isEmpty()) {
    frequency = 0;

    noTone(speakerPin);
    digitalWrite(LED_BUILTIN, LOW);
  } else {
    updateFrequency();

    tone(speakerPin, frequency);
    digitalWrite(LED_BUILTIN, HIGH);
  }
}
