# Registro de gastos

Práctica de Python para abrir y ejecutar en PyCharm. Anotas un gasto, se guarda en `gastos.txt` y la ventana muestra una gráfica de barras por categoría.

## Abrir en PyCharm

1. **File → Open** y elige esta carpeta (`registro_gastos`), no el repositorio entero.
2. Cuando PyCharm lo pida, selecciona un intérprete de **Python 3**.
3. Abre la terminal de PyCharm (abajo) y ejecuta:

   ```bash
   pip install -r requirements.txt
   ```

4. Clic derecho en `interfaz.py` → **Run 'interfaz'**.

Tkinter ya viene con la instalación de Python en Windows y macOS. Matplotlib es la única librería que hay que instalar, porque dibuja la gráfica.

## Módulos

| Archivo | Papel |
| --- | --- |
| `modelo.py` | Clase `Gasto` y el objeto que representa cada apunte. |
| `fichero.py` | Lee y escribe `gastos.txt`. |
| `grafica.py` | Dibuja la gráfica de barras. |
| `interfaz.py` | Ventana. Es el archivo que se ejecuta. |

En cada archivo, `return` aparece una sola vez y es la última instrucción de ese módulo. El programa no usa `break`: el bucle que lee el fichero sale cuando la condición `hay_linea` pasa a ser falsa.

## Entrega

Comprime esta carpeta en un ZIP (sin `__pycache__`) y súbela al campus virtual antes del **25 de enero de 2027**.
