"""Operaciones con el fichero de gastos."""

import os

from modelo import Gasto

carpeta = os.path.dirname(os.path.abspath(__file__))
ruta_gastos = os.path.join(carpeta, "gastos.txt")


def guardar_gasto(ruta, gasto):
    archivo = open(ruta, "a", encoding="utf-8")
    archivo.write(gasto.como_linea() + "\n")
    archivo.close()


def leer_gastos(ruta):
    gastos = []
    archivo_nuevo = open(ruta, "a", encoding="utf-8")
    archivo_nuevo.close()
    archivo = open(ruta, "r", encoding="utf-8")
    linea = archivo.readline()
    hay_linea = linea != ""
    while hay_linea:
        partes = linea.strip().split(";")
        linea_valida = len(partes) == 4
        importe = 0.0
        if linea_valida:
            try:
                importe = float(partes[2].strip().replace(",", "."))
            except ValueError:
                linea_valida = False
        if linea_valida:
            gasto = Gasto(
                partes[0].strip(),
                partes[1].strip(),
                importe,
                partes[3].strip(),
            )
            gastos.append(gasto)
        linea = archivo.readline()
        hay_linea = linea != ""
    archivo.close()
    return gastos
