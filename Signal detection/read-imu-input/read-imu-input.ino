#include <Wire.h> // use the wire library
int mpu = 0x68; // I2C address of MPU-6050
int16_t GyY;

void setup() {
  Serial.begin(9600); // initiate serial communication for sensor data
  Wire.begin();
  Wire.beginTransmission(mpu);
  Wire.write(0x6B); // PWR_MGMT_1 register
  Wire.write(0); // Wake mup MPU-6050
  Wire.endTransmission(true);
}

void loop() {
  Wire.beginTransmission(mpu);
  Wire.write(0x3B);
  Wire.endTransmission(false);
  Wire.requestFrom(mpu,14,true); 
  GyY = Wire.read() <<8|Wire.read();
  Serial.print(GyY);
  Serial.print('\n');
  delay(30); //33
}
