# Reloj segundero con servo 9g

Aguja de segundos para Arduino Uno (o Nano / Mega) y un servo SG90.

El servo recorre unos 180 grados: el segundo 0 queda en 0° y el segundo 59 en 180°.

## Conexión

| Cable del servo | Color típico | Pin del Arduino |
| --- | --- | --- |
| Señal | Naranja o amarillo | D9 |
| VCC | Rojo | 5V |
| GND | Marrón o negro | GND |

Si el Arduino se reinicia al mover el servo, alimenta el servo con 5 V externos y une el GND de esa fuente con el GND del Arduino.

## Uso

1. Abre `reloj-segundero.ino` en el IDE de Arduino.
2. Elige la placa y el puerto.
3. Sube el programa. Al arrancar, la aguja empieza en el segundo 0.
