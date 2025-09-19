#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <Arduino.h>
#include <Wire.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64

#define BUTTON 13

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

int currentScreen = 0;
bool lastButtonState = HIGH;
bool buttonPressed = false;

void showScreen(int screenNumber);

void setup() {
  Serial.begin(115200);
  pinMode(BUTTON, INPUT_PULLUP);

  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;);
  }

  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE);

  showScreen(currentScreen);
}

void showScreen(int screenNumber) {
  display.clearDisplay();
  display.setCursor(0, 0);

  switch (screenNumber) {
    case 0:
      display.println("Screen 1");
      break;
    case 1:
      display.println("Screen 2");
      break;
    case 2:
      display.println("Screen 3");
      break;
  }

  display.display();
  Serial.print("Showing Screen ");
  Serial.println(screenNumber + 1);
}

void loop() {
  bool currentButtonState = digitalRead(BUTTON);

  if (lastButtonState == HIGH && currentButtonState == LOW) {
    buttonPressed = true;
    delay(50);
  }

  if (buttonPressed) {
    currentScreen = (currentScreen + 1) % 3;
    showScreen(currentScreen);
    buttonPressed = false;
  }

  lastButtonState = currentButtonState;
  delay(10);
}