#include <Servo.h>

Servo aguja;
const int PIN_SERVO = 9;

// Ajusta si tu servo no llega exactamente a 0-180
const int ANGULO_MIN = 0;
const int ANGULO_MAX = 180;

unsigned long ultimoSegundo = 0;
int segundo = 0;  // 0..59

void setup() {
  aguja.attach(PIN_SERVO);
  aguja.write(ANGULO_MIN);
  delay(500);
  ultimoSegundo = millis();
}

void loop() {
  // Cada 1000 ms avanza un segundo
  if (millis() - ultimoSegundo >= 1000UL) {
    ultimoSegundo += 1000UL;

    segundo++;
    if (segundo >= 60) {
      segundo = 0;
    }

    // Mapear segundo 0-59 a angulo 0-180
    int angulo = map(segundo, 0, 59, ANGULO_MIN, ANGULO_MAX);
    aguja.write(angulo);
  }
}
