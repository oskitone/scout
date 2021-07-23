#include "Frequency.h"
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
Frequency frequency(glide, CYCLES_PER_GLIDE_MAX);

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
    frequency.print();
  }

  if (buffer.isEmpty()) {
    if (!glideOnFreshKeyPresses) {
      frequency.reset();
    }

    noTone(SPEAKER_PIN);
    digitalWrite(LED_BUILTIN, LOW);
  } else {
    frequency.update(notes.get(buffer.getFirst()) / 4 * pow(2, octave));

    tone(SPEAKER_PIN, frequency.get());
    digitalWrite(LED_BUILTIN, HIGH);
  }
}
