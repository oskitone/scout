/*
  ReadAnalogVoltage

  Reads an analog input on pin 0, converts it to voltage, and prints the result to the Serial Monitor.
  Graphical representation is available using Serial Plotter (Tools > Serial Plotter menu).
  Attach the center pin of a potentiometer to pin A0, and the outside pins to +5V and ground.

  This example code is in the public domain.

  http://www.arduino.cc/en/Tutorial/ReadAnalogVoltage
*/

int buttonPin = 8;

int speakerPin = 12;

int numTones = 10;
int tones[] = {261, 277, 294, 311, 330, 349, 370, 392, 415, 440};
//            mid C  C#   D    D#   E    F    F#   G    G#   A

float freqMin = 65.41;
float freqMax = 1046.5;

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
  pinMode(buttonPin, INPUT_PULLUP);
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  int sensorValue = analogRead(A0);
  // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V):
  float voltage = sensorValue * (5.0 / 1023.0);
  // print out the value you read:
//  Serial.println(voltage);
  Serial.println(digitalRead(buttonPin));

  if (digitalRead(buttonPin) == LOW) {
//    tone(speakerPin, 261 + 179 * (voltage / 5.0));
      tone(speakerPin, freqMin + (freqMax - freqMin) * (voltage / 5.0));
//    delay(5000);
//    noTone(speakerPin);
  } else {
    noTone(speakerPin);
  }

//    tone(speakerPin, tones[0]);

}
