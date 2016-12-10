#include <Wire.h> // use the wire library
int mpu = 0x68; // I2C address of MPU-6050
int16_t AcX, AcY, AcZ, Tmp, GyX, GyY, GyZ;

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
  AcX = Wire.read() <<8|Wire.read();
  AcY = Wire.read() <<8|Wire.read();
  AcZ = Wire.read() <<8|Wire.read();
  Tmp = Wire.read() <<8|Wire.read();
  GyX = Wire.read() <<8|Wire.read();
  GyY = Wire.read() <<8|Wire.read();
  GyZ = Wire.read() <<8|Wire.read();
  Serial.println(GyY/131.0);
  delay(30); //33
}
