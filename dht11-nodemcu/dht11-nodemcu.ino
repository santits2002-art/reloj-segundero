/*
  Sketch al estilo Arduino IoT Cloud
  Thing: DHT11 en NodeMCU 0.9

  Placa en el editor: NodeMCU 0.9 (ESP-12 Module)

  Cableado del DHT11:
    VCC  -> 3.3V
    GND  -> GND
    DATA -> D2 (GPIO4)

  En la Thing crea estas variables, con el mismo nombre:
    temperature   tipo Temperature          permiso Read   cada 10 s
    humidity      tipo Relative Humidity    permiso Read   cada 10 s

  Librerias (Library Manager del editor en la nube):
    DHT sensor library, de Adafruit
    Adafruit Unified Sensor (la pide la anterior)
    ArduinoIoTCloud y Arduino_ConnectionHandler ya vienen con la Thing

  thingProperties.h lo regenera Arduino Cloud al guardar la Thing.
  Este archivo .ino es el que se edita en la pestana Sketch.
*/

#include "arduino_secrets.h"
#include "thingProperties.h"
#include <DHT.h>
#include <ESP8266WiFi.h>

// D2 del NodeMCU 0.9. El core lo define como GPIO4
// al elegir la placa "NodeMCU 0.9 (ESP-12 Module)".
const uint8_t PIN_DHT = D2;
const uint8_t DHT_TIPO = DHT11;

// El DHT11 solo admite una lectura valida cada 2 segundos.
const unsigned long INTERVALO_LECTURA_MS = 2000UL;

DHT dht(PIN_DHT, DHT_TIPO);
unsigned long ultimaLecturaMs = 0;

void setup() {
  Serial.begin(9600);
  delay(1500);

  initProperties();
  ArduinoCloud.begin(ArduinoIoTPreferredConnection);

  setDebugMessageLevel(2);
  ArduinoCloud.printDebugInfo();

  // El protocolo del DHT es sensible al tiempo. Con el modem-sleep
  // del ESP8266 la lectura falla a menudo mientras hay WiFi.
  WiFi.setSleepMode(WIFI_NONE_SLEEP);

  dht.begin();
  ultimaLecturaMs = millis();
}

void loop() {
  ArduinoCloud.update();

  unsigned long ahora = millis();
  if (ahora - ultimaLecturaMs < INTERVALO_LECTURA_MS) {
    return;
  }
  ultimaLecturaMs = ahora;

  float humedad = dht.readHumidity();
  float temperatura = dht.readTemperature();

  if (isnan(humedad) || isnan(temperatura)) {
    Serial.println("Fallo al leer el DHT11. Revisa DATA en D2, 3.3V, GND y la resistencia de pull-up.");
    return;
  }

  temperature = temperatura;
  humidity = humedad;

  Serial.print("Temperatura: ");
  Serial.print(temperatura);
  Serial.print(" C | Humedad: ");
  Serial.print(humedad);
  Serial.println(" %");
}
