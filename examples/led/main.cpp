#include <Arduino.h>

#define LED 4

void setup() {
  Serial.begin(9600);
  pinMode(LED, OUTPUT);
}

void loop() { digitalWrite(LED, HIGH); }