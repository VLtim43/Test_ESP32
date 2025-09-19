#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <Arduino.h>
#include <Wire.h>
#include "display_utils.h"

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

void setup() {
  Serial.begin(115200);

  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;);
  }

  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
}

void loop() {
  display.clearDisplay();

  // Draw some sample bars with different values
  drawBar(5, 5, 118, 10, 25.5, 0, 50, "Value 1: ", "");
  drawBar(5, 25, 118, 10, 75.0, 0, 100, "Value 2: ", "%");
  drawBar(5, 45, 118, 10, -10.2, -20, 40, "Value 3: ", "C");

  display.display();

  delay(2000);

  // Clear and draw different values
  display.clearDisplay();

  drawBar(5, 5, 118, 10, 42.8, 0, 50, "Demo A: ", "");
  drawBar(5, 25, 118, 10, 18.5, 0, 100, "Demo B: ", "%");
  drawBar(5, 45, 118, 10, 30.1, -20, 40, "Demo C: ", "C");

  display.display();

  delay(2000);
}