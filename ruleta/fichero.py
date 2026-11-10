"""Lectura y escritura del historial de tiradas."""

import os

from modelo import Apuesta, saldo_inicial

carpeta = os.path.dirname(os.path.abspath(__file__))
ruta_historial = os.path.join(carpeta, "historial.txt")


def guardar_tirada(ruta, tirada):
    archivo = open(ruta, "a", encoding="utf-8")
    archivo.write(tirada.como_linea() + "\n")
    archivo.close()


def leer_historial(ruta):
    tiradas = []
    saldo_anterior = saldo_inicial
    archivo_nuevo = open(ruta, "a", encoding="utf-8")
    archivo_nuevo.close()
    archivo = open(ruta, "r", encoding="utf-8")
    linea = archivo.readline()
    hay_linea = linea != ""
    while hay_linea:
        partes = linea.strip().split(";")
        linea_valida = len(partes) == 8
        cantidad = 0.0
        numero_salido = 0
        if linea_valida:
            try:
                cantidad = float(partes[0].replace(",", "."))
                numero_salido = int(partes[3])
                if numero_salido < 0 or numero_salido > 36:
                    linea_valida = False
            except ValueError:
                linea_valida = False
        if linea_valida:
            texto_numero = partes[2].strip()
            if texto_numero == "solo":
                texto_numero = ""
            tirada = Apuesta(
                cantidad,
                partes[1].strip(),
                texto_numero,
                numero_salido,
                saldo_anterior,
            )
            tiradas.append(tirada)
            saldo_anterior = tirada.saldo
        linea = archivo.readline()
        hay_linea = linea != ""
    archivo.close()
    return tiradas
