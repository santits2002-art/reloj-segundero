"""Clase Gasto: fecha, concepto, importe y categoria de un apunte."""


class Gasto:
    def __init__(self, fecha, concepto, importe, categoria):
        self.fecha = fecha
        self.concepto = concepto
        self.importe = importe
        self.categoria = categoria

    def como_linea(self):
        texto_importe = "%.2f" % self.importe
        linea = self.fecha + ";" + self.concepto + ";" + texto_importe + ";" + self.categoria
        return linea
