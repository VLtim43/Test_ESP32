// #include <Arduino.h>

// #define LED1 2
// #define LED2 4
// #define LED3 5

// unsigned long previousMillis1 = 0;
// unsigned long previousMillis2 = 0;
// unsigned long previousMillis3 = 0;

// const unsigned long interval1 = 500;
// const unsigned long interval2 = 1000;
// const unsigned long interval3 = 3000;

// bool led1State = false;
// bool led2State = false;
// bool led3State = false;

// void setup() {
//   Serial.begin(115200);

//   pinMode(LED1, OUTPUT);
//   pinMode(LED2, OUTPUT);
//   pinMode(LED3, OUTPUT);

//   digitalWrite(LED1, LOW);
//   digitalWrite(LED2, LOW);
//   digitalWrite(LED3, LOW);
// }

// void loop() {
//   unsigned long currentMillis = millis();

//   // Handle LED1 (500ms interval)
//   if (currentMillis - previousMillis1 >= interval1) {
//     previousMillis1 = currentMillis;
//     led1State = !led1State;
//     digitalWrite(LED1, led1State);
//     Serial.println("LED1 toggled");
//   }

//   if (currentMillis - previousMillis2 >= interval2) {
//     previousMillis2 = currentMillis;
//     led2State = !led2State;
//     digitalWrite(LED2, led2State);
//     Serial.println("LED2 toggled");
//   }

//   if (currentMillis - previousMillis3 >= interval3) {
//     previousMillis3 = currentMillis;
//     led3State = !led3State;
//     digitalWrite(LED3, led3State);
//     Serial.println("LED3 toggled");
//   }
// }