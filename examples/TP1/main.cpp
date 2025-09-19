#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <Arduino.h>
#include <DHTesp.h>
#include <Wire.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64

const int DHT_PIN = 15;
const int PHOTORESISTOR_DIGITAL_PIN = 12;

DHTesp dhtSensor;
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

void drawBar(int x, int y, int width, int height, float value, float minVal,
             float maxVal, String label, String unit) {
  // Draw label text
  display.setCursor(x, y);
  display.print(label);
  display.print(value, 1);
  display.print(unit);

  // Calculate bar fill width based on value range
  int barFillWidth =
      map(constrain(value, minVal, maxVal), minVal, maxVal, 0, width - 2);

  // Draw bar outline
  display.drawRect(x, y + 12, width, height, SSD1306_WHITE);

  // Draw bar fill
  if (barFillWidth > 0) {
    display.fillRect(x + 1, y + 13, barFillWidth, height - 2, SSD1306_WHITE);
  }
}

void setup() {
  Serial.begin(115200);

  // dhtSensor.setup(DHT_PIN, DHTesp::DHT22);
  dhtSensor.setup(DHT_PIN, DHTesp::DHT11);
  // Wokwi only has DH22, but IRL i just have the DH11 sensor.

  pinMode(PHOTORESISTOR_DIGITAL_PIN, INPUT);

  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;);
  }

  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
}

void loop() {
  TempAndHumidity data = dhtSensor.getTempAndHumidity();
  int digitalState = digitalRead(PHOTORESISTOR_DIGITAL_PIN);

  if (dhtSensor.getStatus() != 0) {
    Serial.println("error status: " + String(dhtSensor.getStatusString()));
    delay(2000);
    return;
  }

  display.clearDisplay();

  // Display day/night status at top
  display.setTextSize(1);
  display.setCursor(0, 0);
  if (digitalState == HIGH) {
    display.println("NIGHT");
  } else {
    display.println("DAY");
  }

  drawBar(5, 20, 118, 10, data.temperature, -40, 80, "T:", "C");
  drawBar(5, 45, 118, 10, data.humidity, 0, 100, "H:", "%");

  display.display();

  Serial.println("Temp: " + String(data.temperature, 1) + "°C");
  Serial.println("Humidity: " + String(data.humidity, 1) + "%");
  Serial.println("---");

  delay(2000);
}