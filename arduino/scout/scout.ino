/*
   WiP
*/

#include "KeyBuffer.h"

// SETTINGS
int octave = 3;
float glide = .25;
bool printToSerial = false;
bool glideOnFreshKeyPresses = true;

const int CYCLES_PER_GLIDE_MAX = printToSerial ? 25 : 250;

const float MIDDLE_A = 440;
const int NOTES_COUNT = 17;
const int STARTING_NOTE_DISTANCE_FROM_MIDDLE_A = -9;

const int SPEAKER_PIN = 11;

float getNoteFrequency(int distance, float origin = MIDDLE_A) {
  float frequency_ratio = 1.059463; // pow(2, 1/12)
  return origin * pow(frequency_ratio, distance);
}

float notes[NOTES_COUNT];
void populateNotes() {
  for (int i = 0; i < NOTES_COUNT; i++) {
    notes[i] = getNoteFrequency(STARTING_NOTE_DISTANCE_FROM_MIDDLE_A + i);
  }
}

KeyBuffer buffer;

float frequency = 0;
float glideStep;

float getFrequency(long key) {
  return notes[key] / 4 * pow(2, octave);
}

float getTargetFrequency() {
  return getFrequency(buffer.getFirst());
}

float previousTargetFrequency;
void updateFrequency() {
  float target = getTargetFrequency();
  bool needsUpdate = frequency != target;

  if (needsUpdate) {
    if ((frequency == 0) || (glide == 0)) {
      frequency = target;
    } else {
      if (target != previousTargetFrequency) {
        glideStep = abs(target - previousTargetFrequency)
          / (glide * CYCLES_PER_GLIDE_MAX);
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
  populateNotes();
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
    if (!glideOnFreshKeyPresses) {
      frequency = 0;
    }

    noTone(SPEAKER_PIN);
    digitalWrite(LED_BUILTIN, LOW);
  } else {
    updateFrequency();

    tone(SPEAKER_PIN, frequency);
    digitalWrite(LED_BUILTIN, HIGH);
  }
}
