#include "display_utils.h"

extern Adafruit_SSD1306 display;

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