#ifndef Notes_h
#define Notes_h

#include "Arduino.h"

const int NOTES_COUNT = 17;

class Notes {
  public:
    Notes(int startingNoteDistanceFromMiddleA);
    float get(int i);
  private:
    float _notes[NOTES_COUNT];
};

#endif
