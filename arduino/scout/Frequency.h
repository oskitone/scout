#ifndef Frequency_h
#define Frequency_h

#include "Arduino.h"
#include "Notes.h"

class Frequency {
  public:
    Frequency(float glide, int cyclesPerGlideMax);
    void update(float target);
    float get();
    void reset();
    void print();
  private:
    float _frequency = 0;
    float _glide;
    float _glideStep;
    float _previousTarget;
    float _target;
    int _cyclesPerGlideMax;
};

#endif
