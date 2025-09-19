#include <Arduino.h>

const int PHOTORESISTOR_DIGITAL_PIN = 12;
const int DAY_LED_PIN = 5;
const int NIGHT_LED_PIN = 4;

void setup() {
  Serial.begin(115200);
  delay(1000);

  pinMode(PHOTORESISTOR_DIGITAL_PIN, INPUT);
  pinMode(DAY_LED_PIN, OUTPUT);
  pinMode(NIGHT_LED_PIN, OUTPUT);

  Serial.println("Photosensor Digital Day/Night LED Example");
  Serial.println("Reading digital light state...");
}

void loop() {
  int digitalState = digitalRead(PHOTORESISTOR_DIGITAL_PIN);

  if (digitalState == HIGH) {
    digitalWrite(NIGHT_LED_PIN, HIGH);
    digitalWrite(DAY_LED_PIN, LOW);
    Serial.println("◐ NIGHT");
  } else {
    digitalWrite(DAY_LED_PIN, HIGH);
    digitalWrite(NIGHT_LED_PIN, LOW);
    Serial.println("☼ DAY");
  }

  delay(1000);
}