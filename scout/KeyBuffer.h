#define CIRCULAR_BUFFER_DEBUG
#include <CircularBuffer.h>
#include <Keypad.h>

/*
  WiP
*/
#ifndef KeyBuffer_h
#define KeyBuffer_h

#include "Arduino.h"

class KeyBuffer {
  public:
    KeyBuffer();
    bool isEmpty();
    char getFirst();
    void print();
    void printBuffer();
    void populate();
  private:
    CircularBuffer<int, 4> _buffer;
    // Keypad _buttons;

    bool isInBuffer(int c);
    bool removeFromBuffer(int c);
};

#endif
