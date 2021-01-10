/*
   WiP
 */

#include <Keypad.h>

int speakerPin = 12;

const byte ROWS = 4;
const byte COLS = 4;
// intentionally 1-indexed because 0 is null?
byte key_indexes[ROWS][COLS] = {
    {1,5,9,13},
    {2,6,10,14},
    {3,7,11,15},
    {4,8,12,16},
};
float notes[] = {523, 554, 587, 622, 659, 698, 740, 784, 831, 880, 932, 988, 1047, 1109, 1175, 1245};
byte rowPins[ROWS] = {6,10,11,4};
byte colPins[COLS] = {8,5,3,7};

Keypad buttons = Keypad( makeKeymap(key_indexes), rowPins, colPins, ROWS, COLS );

void setup() {
        Serial.begin(9600);
        pinMode(LED_BUILTIN, OUTPUT);
//        buttons.setDebounceTime(0);
}

void loop() {
        byte key = buttons.getKey();
//        Serial.println(buttons.getKeys());

        if (key > 0) { // TODO: confirm acceptable
                Serial.println(key);
                tone(speakerPin, notes[key - 1]);
                digitalWrite(LED_BUILTIN, HIGH);
        } else if (buttons.getState() == IDLE) {
                noTone(speakerPin);
                digitalWrite(LED_BUILTIN, LOW);
        }
}
