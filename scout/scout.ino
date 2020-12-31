/*
   WiP
 */

int inputPin = A0;
int buttonPin = 8;
int speakerPin = 12;

float freqMin = 65.41;
float freqMax = 1046.5;

const int numReadings = 10;

int readings[numReadings];      // the readings from the analog input
int readIndex = 0;              // the index of the current reading
int total = 0;                  // the running total
int average = 0;                // the average

void setup() {
        Serial.begin(9600);
        pinMode(buttonPin, INPUT_PULLUP);
        pinMode(LED_BUILTIN, OUTPUT);

        for (int thisReading = 0; thisReading < numReadings; thisReading++) {
                readings[thisReading] = 0;
        }
}

void loop() {
        // subtract the last reading:
        total = total - readings[readIndex];
        // read from the sensor:
        readings[readIndex] = analogRead(A0);
        // add the reading to the total:
        total = total + readings[readIndex];
        // advance to the next position in the array:
        readIndex = readIndex + 1;

        // if we're at the end of the array...
        if (readIndex >= numReadings) {
                // ...wrap around to the beginning:
                readIndex = 0;
        }

        // calculate the average:
        average = total / numReadings;

        Serial.println(average);

        float voltage = average * (5.0 / 1023.0);
        float frequency = freqMin + (freqMax - freqMin) * (voltage / 5.0);

        if (digitalRead(buttonPin) == LOW) {
                tone(speakerPin, frequency);
                digitalWrite(LED_BUILTIN, HIGH);
        } else {
                noTone(speakerPin);
                digitalWrite(LED_BUILTIN, LOW);
        }
}
