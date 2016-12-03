#include <Wire.h>
#include "pitches.h" //Header file with pitch definitions
const int SPEAKER = 10; //Speker Pin
//Note Array
int notes[] = {NOTE_D4, NOTE_C4};
//The Duration of each note (in ms)
int times[] = {250, 250};
const int MOTOR = 9;
const int led = 12;
int speed = 0;
int mpu = 0x68;
int16_t AcX, AcY, AcZ, Tmp, GyX, GyY, GyZ;
long prevGy = 0;
long currGy;
long localMaxGy;
int count;
int index = 0;
double amplitude;
int ampThreshold = 300;
int period;
int perThreshold = 0.6; //20*0.03
int zerosIndices[] = {0, 0};
int prevZeroIndex = 0;


void setup() {
  pinMode(MOTOR, OUTPUT);
  pinMode(led, OUTPUT);
  Play each note for the right duration
  for (int i = 0; i < 2; i++) {
    tone(SPEAKER, notes[i], times[i]);
    delay(times[i]);
  }
  Serial.begin(9600);
  Wire.begin();
  Wire.beginTransmission(mpu);
  Wire.write(0x6B);
  Wire.write(0);
  Wire.endTransmission(true);
}

void loop() {  
  Wire.beginTransmission(mpu);
  Wire.write(0x3B);
  Wire.endTransmission(false);
  Wire.requestFrom(mpu, 14, true);
  AcX = Wire.read() << 8 | Wire.read();
  AcY = Wire.read() << 8 | Wire.read();
  AcZ = Wire.read() << 8 | Wire.read();
  Tmp = Wire.read() << 8 | Wire.read();
  GyX = Wire.read() << 8 | Wire.read();
  GyY = Wire.read() << 8 | Wire.read();
  GyZ = Wire.read() << 8 | Wire.read();
  currGy = filter(GyY/131.0);
  append(currGy);
  // freezingOfGait will call your alogrithm which we'll say returns a boolean
  if (count == 3) { // freezing of gait detected
    Serial.println("Freezing");
    speed = 250; //255 is max motor speed, 250 to be safe
    analogWrite(MOTOR, speed);
    digitalWrite(led, HIGH);
    for (int i = 0; i < 2; i++) {
      tone(SPEAKER, notes[i], times[i]);
      delay(times[i]);
    }
    count = 0;
  }
  else {
    speed = 0;
    analogWrite(MOTOR, speed);
    digitalWrite(led, LOW);
  }
  prevGy = currGy;
  index++;
  delay(30);
}

long filter(long Gy) {
  if (abs(Gy - prevGy) < 20) return prevGy; // small fluctuation
  return Gy;
}

void append(long currentGy) {
  if (currentGy == 0 || currentGy * prevGy < 0) {
    if (index - prevZeroIndex > 1) { // not stopping
      if (zerosIndices[1] != 0) {
        period = (index - zerosIndices[0]) * 0.03;
        zerosIndices[0] = index;
        zerosIndices[1] = 0;
        amplitude += localMaxGy;
        localMaxGy = 0;
        Serial.print("Period: ");
        Serial.println(period);
        Serial.print("Amplitude: ");
        Serial.println(amplitude);
        if (isFreezing()) count++;
        Serial.print("Count: ");
        Serial.println(count);
        amplitude = 0.0;
        period = 0;
      }
      else if (zerosIndices[0] != 0) {
        zerosIndices[1] = index;
        amplitude += localMaxGy;
        localMaxGy = 0;
      }
      else {
        zerosIndices[0] = index;
        localMaxGy = 0;
      }
    }
    prevZeroIndex = index;
  }
  else {
    if (abs(currentGy) > localMaxGy) localMaxGy = abs(currentGy);
  }
}

bool isFreezing() {
  return (amplitude < ampThreshold) || (period < perThreshold);
}
