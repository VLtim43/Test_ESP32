#ifndef DISPLAY_UTILS_H
#define DISPLAY_UTILS_H

#include <Adafruit_SSD1306.h>
#include <Arduino.h>

void drawBar(int x, int y, int width, int height, float value, float minVal,
             float maxVal, String label, String unit);

#endif