#include <Arduino.h>
#include <DHTesp.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include "display_utils.h"

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1
#define SCREEN_ADDRESS 0x3C

const int DHT_PIN = 15;

DHTesp dhtSensor;
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

void setup() {
  Serial.begin(115200);

  dhtSensor.setup(DHT_PIN, DHTesp::DHT22);

  if (!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;);
  }

  display.display();
  delay(2000);
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
}

void loop() {
  TempAndHumidity data = dhtSensor.getTempAndHumidity();

  if (dhtSensor.getStatus() != 0) {
    Serial.println("DHT22 error status: " + String(dhtSensor.getStatusString()));
    delay(2000);
    return;
  }

  display.clearDisplay();

  drawBar(5, 5, 118, 10, data.temperature, -40, 80, "T:", "C");
  drawBar(5, 35, 118, 10, data.humidity, 0, 100, "H:", "%");

  display.display();

  Serial.println("Temp: " + String(data.temperature, 1) + "°C");
  Serial.println("Humidity: " + String(data.humidity, 1) + "%");
  Serial.println("---");

  delay(2000);
}