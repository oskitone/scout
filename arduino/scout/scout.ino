/*
   WiP
*/

#include "KeyBuffer.h"

int OCTAVE_RANGE = 6;
float GLIDE_STEP_RANGE = 2;

int octaveControlPin = A0;
int glideStepControlPin = A1;
int speakerPin = 12;
bool printToSerial = false;

float notes[] = {174.61, 185.00, 196.00, 207.65, 220.00, 233.08, 246.94, 261.63, 277.18, 293.66, 311.13, 329.63, 349.23, 369.99, 392.00, 415.30, 440.00, 466.16, 493.88, 523.25};

KeyBuffer buffer;

int octave = OCTAVE_RANGE / 2;
float glide = .5;

float POT_TOLERANCE = .05;

long settingsThrottle = 500;

float frequency = 0;
float glideStep = glide * GLIDE_STEP_RANGE;

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

void updateFrequency() {
  float target = getTargetFrequency();

  if ((frequency == 0) || (glide <= POT_TOLERANCE)) {
    frequency = target;
  } else if (frequency != target) {
    frequency = (target > frequency)
                ? min(target, frequency + glideStep)
                : max(target, frequency - glideStep);
  }
}

float getVoltage(int pin) {
  return analogRead(pin) * (5.0 / 1023.0) / 5;
}

unsigned long settingsPreviousMillis = 0;
void updateSettings() {
  unsigned long currentMillis = millis();

  if ((unsigned long)(currentMillis - settingsPreviousMillis) >= settingsThrottle) {
    octave = round(getVoltage(octaveControlPin) * (OCTAVE_RANGE - 1)) + 1;

    glide = getVoltage(glideStepControlPin);
    glideStep = GLIDE_STEP_RANGE - glide * GLIDE_STEP_RANGE;

    settingsPreviousMillis = millis();
  }
}

void loop() {
  buffer.populate();

  updateSettings();

  if (printToSerial) {
    Serial.println(
      "frequency: " + String(frequency)
      + "\ttarget: " + String(getTargetFrequency())
      + "glideStep: " + String(glideStep)
      + "  glide: " + String(glide)
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
