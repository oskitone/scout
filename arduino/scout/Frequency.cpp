#include "Arduino.h"
#include "Frequency.h"
#include "Notes.h"

Frequency::Frequency(float glide, int cyclesPerGlideMax) {
  _glide = glide;
  _cyclesPerGlideMax = cyclesPerGlideMax;
}

float Frequency::get() {
  return _frequency;
}

void Frequency::update(float target) {
  _target = target;
  bool needsUpdate = _frequency != _target;

  if (needsUpdate) {
    if ((_frequency == 0) || (_glide == 0)) {
      _frequency = _target;
    } else {
      if (_target != _previousTarget) {
        _glideStep = abs(_target - _previousTarget)
                     / (_glide * _cyclesPerGlideMax);
      }

      _frequency = (_target > _frequency)
                   ? min(_target, _frequency + _glideStep)
                   : max(_target, _frequency - _glideStep);
    }
  }

  if (!needsUpdate) {
    _previousTarget = _target;
  }
}

void Frequency::reset() {
  _frequency = 0;
}

void Frequency::print() {
  Serial.println(
    "frequency:" + String(_frequency)
    + ",target:" + String(_target)
    + ",previousTargetFrequency:" + String(_previousTarget)
  );
}
