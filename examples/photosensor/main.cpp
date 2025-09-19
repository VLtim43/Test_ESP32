#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <Arduino.h>
#include <Wire.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64

const int PHOTORESISTOR_DIGITAL_PIN = 12;

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

void setup() {
  Serial.begin(115200);
  delay(1000);

  pinMode(PHOTORESISTOR_DIGITAL_PIN, INPUT);

  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;);
  }

  display.clearDisplay();
  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 0);
  display.println("Light");
  display.println("Sensor");
  display.display();
  delay(2000);
}

void loop() {
  int digitalState = digitalRead(PHOTORESISTOR_DIGITAL_PIN);

  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0, 10);

  if (digitalState == HIGH) {
    display.println("NIGHT");
  } else {
    display.println("DAY");
  }

  display.display();
  delay(1000);
}