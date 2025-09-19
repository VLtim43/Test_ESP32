#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <Arduino.h>
#include <DHTesp.h>
#include <Wire.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64

const int DHT_PIN = 15;
const int PHOTORESISTOR_DIGITAL_PIN = 12;
const int BUTTON = 13;

DHTesp dhtSensor;
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

int currentScreen = 0;
bool lastButtonState = HIGH;
bool buttonPressed = false;

void showScreen(int screenNumber);

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
  pinMode(BUTTON, INPUT_PULLUP);

  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;);
  }

  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
}

void showScreen(int screenNumber) {
  TempAndHumidity data = dhtSensor.getTempAndHumidity();
  int digitalState = digitalRead(PHOTORESISTOR_DIGITAL_PIN);

  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);

  switch (screenNumber) {
    case 0:
      // Original TP1 screen with temperature and humidity
      if (dhtSensor.getStatus() != 0) {
        display.setCursor(0, 0);
        display.println("DHT Error");
        break;
      }

      // Display day/night status at top
      display.setCursor(0, 0);
      if (digitalState == HIGH) {
        display.println("NIGHT");
      } else {
        display.println("DAY");
      }

      drawBar(5, 20, 118, 10, data.temperature, -40, 80, "T:", "C");
      drawBar(5, 45, 118, 10, data.humidity, 0, 100, "H:", "%");
      break;

    case 1:
      display.setCursor(0, 0);
      display.setTextSize(2);
      display.println("Screen 2");
      break;

    case 2:
      display.setCursor(0, 0);
      display.setTextSize(2);
      display.println("Screen 3");
      break;
  }

  display.display();

  // Serial output for original screen
  if (screenNumber == 0 && dhtSensor.getStatus() == 0) {
    Serial.println("Temp: " + String(data.temperature, 1) + "°C");
    Serial.println("Humidity: " + String(data.humidity, 1) + "%");
    Serial.println("---");
  }
}

void loop() {
  bool currentButtonState = digitalRead(BUTTON);

  if (lastButtonState == HIGH && currentButtonState == LOW) {
    buttonPressed = true;
    delay(50);
  }

  if (buttonPressed) {
    currentScreen = (currentScreen + 1) % 3;
    Serial.print("Switching to Screen ");
    Serial.println(currentScreen + 1);
    buttonPressed = false;
  }

  showScreen(currentScreen);
  lastButtonState = currentButtonState;
  delay(100);
}