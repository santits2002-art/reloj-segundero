"""Grafica de barras con el total de cada categoria."""


def dibujar_grafica(ejes, gastos):
    claves = ["comida", "transporte", "ocio", "otros"]
    nombres = ["Comida", "Transporte", "Ocio", "Otros"]
    colores = ["#2f6f4e", "#3d6f8f", "#c47b2b", "#8a8175"]
    totales = [0.0, 0.0, 0.0, 0.0]

    for gasto in gastos:
        posicion = 0
        encontrado = False
        while posicion < len(claves):
            if gasto.categoria == claves[posicion]:
                totales[posicion] = totales[posicion] + gasto.importe
                encontrado = True
            posicion = posicion + 1
        if not encontrado:
            totales[3] = totales[3] + gasto.importe

    maximo = 0.0
    indice = 0
    total_general = 0.0
    while indice < len(totales):
        total_general = total_general + totales[indice]
        if totales[indice] > maximo:
            maximo = totales[indice]
        indice = indice + 1

    ejes.clear()
    ejes.set_facecolor("#fffdf8")
    ejes.bar(nombres, totales, color=colores, width=0.62, zorder=3)
    texto_total = ("%.2f" % total_general).replace(".", ",")
    ejes.set_title(
        "Gastos por categoría\nTotal: " + texto_total + " €",
        fontsize=13,
        color="#1e3a34",
        pad=10,
    )
    ejes.set_ylabel("Euros", color="#1e3a34")
    ejes.tick_params(colors="#24312c")
    ejes.spines["top"].set_visible(False)
    ejes.spines["right"].set_visible(False)
    ejes.yaxis.grid(True, linestyle="--", linewidth=0.6, color="#d9d3c7", zorder=0)
    ejes.set_axisbelow(True)
    if maximo <= 0:
        ejes.set_ylim(0, 1)
    else:
        ejes.set_ylim(0, maximo * 1.35)

    indice = 0
    while indice < len(totales):
        texto_barra = ("%.2f" % totales[indice]).replace(".", ",")
        ejes.text(
            indice,
            totales[indice],
            texto_barra + " €",
            ha="center",
            va="bottom",
            fontsize=9,
            color="#1e3a34",
        )
        indice = indice + 1

    figura = ejes.figure
    figura.tight_layout()
    return "Gráfica actualizada"
