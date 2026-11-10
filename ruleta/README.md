# Ruleta de casino

Práctica de Python para abrir y ejecutar en PyCharm. El jugador apuesta una cantidad a verde, rojo o negro. Puede apostar solo al color o también a un número de ese color. Cada tirada se guarda en `historial.txt` y la ventana muestra cuántas bolas han salido de cada color.

En la ruleta de casino el **0 es el único verde**. El rojo y el negro son el resto de números, del 1 al 36.

## Premios

La apuesta se descuenta del saldo. Si aciertas, recibes la apuesta multiplicada:

| Apuesta | Premio |
| --- | --- |
| Solo verde | x10 |
| Solo rojo o solo negro | x2 |
| Verde y el número 0 | x10 y x3, o sea x30 |
| Rojo o negro y su número | x2 y x3, o sea x6 |

Si no aciertas, la apuesta se pierde. El saldo inicial es 100 € y sigue guardado en el historial.

## Abrir en PyCharm

1. **File → Open** y elige esta carpeta (`ruleta`).
2. Selecciona un intérprete de **Python 3**.
3. En la terminal de PyCharm:

   ```bash
   pip install -r requirements.txt
   ```

4. Clic derecho en `interfaz.py` → **Run 'interfaz'**.

## Módulos

| Archivo | Papel |
| --- | --- |
| `modelo.py` | Clase `Apuesta` y los números de la ruleta. |
| `fichero.py` | Lee y escribe `historial.txt`. |
| `grafica.py` | Dibuja la gráfica de barras. |
| `interfaz.py` | Ventana. Es el archivo que se ejecuta. |

En cada archivo, `return` aparece una sola vez y es la última instrucción de ese módulo. El programa no usa `break`.

## Entrega

Comprime esta carpeta en un ZIP (sin `__pycache__`) y súbela al campus virtual antes del **25 de enero de 2027**.
