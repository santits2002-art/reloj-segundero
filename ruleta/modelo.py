"""Ruleta europea: casillas, colores y la apuesta de una tirada."""

saldo_inicial = 100.0

numeros_rojos = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
numeros_negros = [2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35]
orden_ruleta = [
    0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10,
    5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26,
]

colores_casillas = []
indice_casilla = 0
while indice_casilla <= 36:
    colores_casillas.append("rojo")
    indice_casilla = indice_casilla + 1

indice_casilla = 0
while indice_casilla < len(numeros_rojos):
    colores_casillas[numeros_rojos[indice_casilla]] = "rojo"
    indice_casilla = indice_casilla + 1

indice_casilla = 0
while indice_casilla < len(numeros_negros):
    colores_casillas[numeros_negros[indice_casilla]] = "negro"
    indice_casilla = indice_casilla + 1

colores_casillas[0] = "verde"


class Apuesta:
    def __init__(self, cantidad, color_elegido, numero_elegido, numero_salido, saldo_anterior):
        self.cantidad = cantidad
        self.color_elegido = color_elegido
        self.numero_elegido = numero_elegido
        self.numero_salido = numero_salido
        self.color_salido = colores_casillas[numero_salido]
        self.multiplicador = 0
        acierto_color = self.color_elegido == self.color_salido
        acierto_numero = False
        if self.numero_elegido != "":
            if int(self.numero_elegido) == self.numero_salido:
                acierto_numero = True
        if acierto_color and self.numero_elegido == "":
            if self.color_elegido == "verde":
                self.multiplicador = 10
            else:
                self.multiplicador = 2
        if acierto_color and acierto_numero:
            if self.color_elegido == "verde":
                self.multiplicador = 10 * 3
            else:
                self.multiplicador = 2 * 3
        self.ganancia = self.cantidad * self.multiplicador
        self.saldo = saldo_anterior - self.cantidad + self.ganancia

    def como_linea(self):
        texto_numero = "solo"
        if self.numero_elegido != "":
            texto_numero = str(self.numero_elegido)
        linea = (
            "%.2f" % self.cantidad
            + ";"
            + self.color_elegido
            + ";"
            + texto_numero
            + ";"
            + str(self.numero_salido)
            + ";"
            + self.color_salido
            + ";"
            + str(self.multiplicador)
            + ";"
            + "%.2f" % self.ganancia
            + ";"
            + "%.2f" % self.saldo
        )
        return linea
