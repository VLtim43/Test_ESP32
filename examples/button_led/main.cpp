#include <Arduino.h>

#define LED 2
#define BUTTON 13

void setup() {
  Serial.begin(9600);
  pinMode(LED, OUTPUT);
  pinMode(BUTTON, INPUT_PULLUP);
}

void loop() {
  bool buttonStatus = digitalRead(BUTTON);

  if (buttonStatus == LOW) {
    digitalWrite(LED, HIGH);  // Turn LED on
    Serial.println("Button pressed - LED ON");
  } else {
    digitalWrite(LED, LOW);  // Turn LED off
    Serial.println("Button released - LED OFF");
  }

  delay(100);
}