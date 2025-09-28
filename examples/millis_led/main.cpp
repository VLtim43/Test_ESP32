#include <Arduino.h>

#define LED_GREEN 5
#define LED_YELLOW 4
#define LED_RED 2

unsigned long previousMillis = 0;
int trafficState = 0;

void setup() {

  Serial.begin(115200);

  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_YELLOW, OUTPUT);
  pinMode(LED_RED, OUTPUT);

  digitalWrite(LED_GREEN, HIGH);
  digitalWrite(LED_YELLOW, LOW);
  digitalWrite(LED_RED, LOW);
}
void loop() {

  unsigned long currentMillis = millis();

  if (trafficState == 0 && currentMillis - previousMillis >= 4000) {
    digitalWrite(LED_GREEN, LOW);
    digitalWrite(LED_YELLOW, HIGH);

    trafficState = 1;
    previousMillis = currentMillis;
  }

  if (trafficState == 1 && currentMillis - previousMillis >= 1000) {
    digitalWrite(LED_YELLOW, LOW);
    digitalWrite(LED_RED, HIGH);

    trafficState = 2;
    previousMillis = currentMillis;
  }

  if (trafficState == 2 && currentMillis - previousMillis >= 5000) {
    digitalWrite(LED_RED, LOW);
    digitalWrite(LED_GREEN, HIGH);

    trafficState = 0;
    previousMillis = currentMillis;
  }
}