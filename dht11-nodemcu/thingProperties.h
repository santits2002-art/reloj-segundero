// Misma forma que el archivo que genera Arduino IoT Cloud.
// Si la Thing ya existe en la nube, no sustituyas el archivo generado:
// basta con que las variables se llamen temperature, humidity y control.

#include <ArduinoIoTCloud.h>
#include <Arduino_ConnectionHandler.h>

const char DEVICE_LOGIN_NAME[] = "00000000-0000-0000-0000-000000000000";

const char SSID[] = SECRET_SSID;
const char PASS[] = SECRET_OPTIONAL_PASS;
const char DEVICE_KEY[] = SECRET_DEVICE_KEY;

CloudTemperature temperature;
CloudRelativeHumidity humidity;
bool control;

void onControlChange();

void initProperties() {
  ArduinoCloud.setBoardId(DEVICE_LOGIN_NAME);
  ArduinoCloud.setSecretDeviceKey(DEVICE_KEY);
  ArduinoCloud.addProperty(temperature, Permission::Read).publishEvery(10 * SECONDS);
  ArduinoCloud.addProperty(humidity, Permission::Read).publishEvery(10 * SECONDS);
  ArduinoCloud.addProperty(control, Permission::ReadWrite).onUpdate(onControlChange);
}

WiFiConnectionHandler ArduinoIoTPreferredConnection(SSID, PASS);
