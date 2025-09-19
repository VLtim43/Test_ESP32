#include <Arduino.h>

#define LED 2

void setup() {
  Serial.begin(9600);
  pinMode(LED, OUTPUT);
}

void loop() { digitalWrite(LED, HIGH); }