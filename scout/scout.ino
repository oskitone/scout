/*
   WiP
 */

int buttonPin = 8;
int speakerPin = 12;

float freqMin = 65.41;
float freqMax = 1046.5;

void setup() {
        Serial.begin(9600);
        pinMode(buttonPin, INPUT_PULLUP);
}

void loop() {
        float voltage = analogRead(A0) * (5.0 / 1023.0);
        float frequency = freqMin + (freqMax - freqMin) * (voltage / 5.0);

        if (digitalRead(buttonPin) == LOW) {
                tone(speakerPin, frequency);
        } else {
                noTone(speakerPin);
        }
}
