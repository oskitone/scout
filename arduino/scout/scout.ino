#include "KeyBuffer.h"
#include "Notes.h"

// SETTINGS
int octave = 3;
float glide = .25;
bool glideOnFreshKeyPresses = true;
bool printToSerial = false;

const int CYCLES_PER_GLIDE_MAX = printToSerial ? 25 : 250;
const int STARTING_NOTE_DISTANCE_FROM_MIDDLE_A = -9;

const int SPEAKER_PIN = 11;

Notes notes(STARTING_NOTE_DISTANCE_FROM_MIDDLE_A);
KeyBuffer buffer;

float getFrequency(long key) {
  return notes.get(key) / 4 * pow(2, octave);
}

float getTargetFrequency() {
  return getFrequency(buffer.getFirst());
}

float frequency = 0;
float glideStep;
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

void blink(int count = 2, int wait = 200) {
  while (count >= 0) {
    digitalWrite(LED_BUILTIN, HIGH);
    delay(wait);
    digitalWrite(LED_BUILTIN, LOW);
    delay(wait);

    count = count - 1;
  }
}

void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);

  blink();
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
