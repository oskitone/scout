#define CIRCULAR_BUFFER_DEBUG
#include <CircularBuffer.h>
#include <Keypad.h>

#ifndef KeyBuffer_h
#define KeyBuffer_h

#include "Arduino.h"

#define BUFFER_MAX 4

class KeyBuffer {
  public:
    KeyBuffer();
    bool isEmpty();
    char getFirst();
    void print();
    void printBuffer();
    void populate();
  private:
    CircularBuffer<int, BUFFER_MAX> _buffer;
    bool isInBuffer(int c);
    bool removeFromBuffer(int c);
};

#endif
