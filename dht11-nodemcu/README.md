# DHT11 en NodeMCU 0.9 (Arduino IoT Cloud)

Temperatura y humedad con un DHT11. El programa publica las lecturas en Arduino IoT Cloud. Un interruptor del dashboard habilita el LED de la placa cuando la temperatura supera 23 °C.

## Cableado

| DHT11 | NodeMCU 0.9 |
| --- | --- |
| VCC | 3.3V |
| GND | GND |
| DATA | D2 (GPIO4) |

Si el DHT11 es el componente suelto de 4 patas, pon una resistencia de 10 kΩ entre DATA y 3.3V. Los módulos en placa pequeña ya la traen. La pata NC no se conecta.

El pin DATA del ESP8266 no admite 5 V. Deja el sensor en 3.3V.

## Thing en Arduino IoT Cloud

1. Entra en [Arduino IoT Cloud](https://app.arduino.cc/dashboards) y crea un Device de terceros, tipo ESP8266. Anota el Device ID y la Secret Key.
2. Crea una Thing y asociale ese dispositivo. En la red, escribe el SSID y la contraseña del WiFi.
3. Añade dos variables, con estos nombres exactos:

| Nombre | Tipo | Permiso | Actualización |
| --- | --- | --- | --- |
| `temperature` | Temperature | Read | Periodically, 10 seconds |
| `humidity` | Relative Humidity | Read | Periodically, 10 seconds |
| `control` | Boolean | Read & Write | On change |

4. Abre la pestaña Sketch. El editor ya tiene `thingProperties.h` y `arduino_secrets.h`. No hace falta pegar esos dos archivos si la Thing está creada: sustituye solo el sketch por `dht11-nodemcu.ino`.
5. En Library Manager instala **DHT sensor library** (Adafruit). Acepta también **Adafruit Unified Sensor**.
6. Placa: **NodeMCU 0.9 (ESP-12 Module)**. Sube el programa.

En el dashboard enlaza `temperature` a un gauge o un chart en °C, `humidity` a otro en %, y `control` a un Switch.

## LED de la placa

El LED azul del NodeMCU 0.9 está en GPIO2 (`LED_BUILTIN`) y enciende con nivel bajo. No hace falta cablear nada.

Se enciende solo si las dos cosas se cumplen:

1. El switch `control` del dashboard está activado.
2. La temperatura leída es mayor que 23 °C.

Si apagas el switch, o la temperatura baja a 23 °C o menos, el LED se apaga. El DHT11 da grados enteros, así que el cambio se ve al pasar de 23 a 24.

## Monitor serie

A 9600 baudios verás la conexión a la nube y, cada 2 segundos, una línea como esta:

```
Temperatura: 26.00 C | Humedad: 48.00 % | Control: activado | LED: encendido
```

El DHT11 cambia de grado en grado y de 1 % en 1 %. La nube recibe el valor cada 10 segundos, aunque la lectura local sea más frecuente. Así el dashboard no se queda congelado cuando la cifra no cambia.

Si el monitor repite el fallo de lectura, revisa que DATA esté en D2 y que el pull-up exista. La primera lectura tras el arranque a veces falla; la siguiente, 2 segundos después, suele ser válida.
