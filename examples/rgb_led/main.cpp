#include <Arduino.h>

#define RED_PIN 5
#define GREEN_PIN 4
#define BLUE_PIN 2


void setup() {
  Serial.begin(115200);
  pinMode(RED_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(BLUE_PIN, OUTPUT);
}

void loop() {
  for (int i = 0; i < 8; i++) {
    digitalWrite(RED_PIN, (i & 1) ? HIGH : LOW);
    digitalWrite(GREEN_PIN, (i & 2) ? HIGH : LOW);
    digitalWrite(BLUE_PIN, (i & 4) ? HIGH : LOW);
    delay(1000);
  }
}