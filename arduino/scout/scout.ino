/*
   WiP
*/

#include "KeyBuffer.h"

bool printToSerial = false;

int OCTAVE_RANGE = 6;
int CYCLES_PER_GLIDE_MAX = printToSerial ? 100 : 1000;

int octaveControlPin = A0;
int glideControlPin = A1;
int speakerPin = 11;

float notes[] = {174.61, 185.00, 196.00, 207.65, 220.00, 233.08, 246.94, 261.63, 277.18, 293.66, 311.13, 329.63, 349.23, 369.99, 392.00, 415.30, 440.00, 466.16, 493.88, 523.25};

KeyBuffer buffer;

int octave = OCTAVE_RANGE / 2;
float glide = .5;

float POT_TOLERANCE = .01;

long settingsThrottle = 500;

float frequency = 0;
float glideStep;

float getFrequency(long key) {
  return notes[key] / 2 * octave;
}

float getTargetFrequency() {
  return getFrequency(buffer.getFirst());
}

float previousTargetFrequency;
void updateFrequency() {
  float target = getTargetFrequency();
  bool needsUpdate = frequency != target;

  if (needsUpdate) {
    if ((frequency == 0) || (glide <= POT_TOLERANCE)) {
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

float getVoltage(int pin) {
  return analogRead(pin) * (5.0 / 1023.0) / 5;
}

unsigned long settingsPreviousMillis = 0;
void updateSettings(bool skipPoll = false) {
  bool pollPasses =
    (unsigned long)(millis() - settingsPreviousMillis) >= settingsThrottle;

  if (skipPoll || pollPasses) {
    octave = round(getVoltage(octaveControlPin) * (OCTAVE_RANGE - 1)) + 1;
    glide = getVoltage(glideControlPin);

    settingsPreviousMillis = millis();
  }
}

void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);

  updateSettings(true);
}

void loop() {
  buffer.populate();

  updateSettings();

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
