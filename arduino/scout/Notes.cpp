#include "Arduino.h"
#include "Notes.h"

const float MIDDLE_A = 440;
const float FREQUENCY_RATIO = 1.059463; // magic! 2 to the power of 1/12

float getNoteFrequency(int distance, float origin = MIDDLE_A) {
  return origin * pow(FREQUENCY_RATIO, distance);
}

Notes::Notes(int startingNoteDistanceFromMiddleA) {
  for (int i = 0; i < NOTES_COUNT; i++) {
    _notes[i] = getNoteFrequency(startingNoteDistanceFromMiddleA + i);
  }
}

float Notes::get(int i) {
  return _notes[i];
}
