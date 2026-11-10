"""Grafica de barras con las bolas de cada color."""


def dibujar_grafica(ejes, tiradas):
    nombres = ["Verde", "Rojo", "Negro"]
    claves = ["verde", "rojo", "negro"]
    colores = ["#1f8a4c", "#c0392b", "#d9d9d9"]
    totales = [0, 0, 0]
    for tirada in tiradas:
        indice = 0
        while indice < len(claves):
            if tirada.color_salido == claves[indice]:
                totales[indice] = totales[indice] + 1
            indice = indice + 1

    maximo = 0
    indice = 0
    while indice < len(totales):
        if totales[indice] > maximo:
            maximo = totales[indice]
        indice = indice + 1

    ejes.clear()
    ejes.set_facecolor("#10281f")
    ejes.bar(nombres, totales, color=colores, width=0.62, zorder=3)
    ejes.set_title("Bolas por color", color="#f4f1ea", fontsize=13, pad=8)
    ejes.set_ylabel("Tiradas", color="#f4f1ea")
    ejes.tick_params(colors="#f4f1ea")
    ejes.spines["top"].set_visible(False)
    ejes.spines["right"].set_visible(False)
    ejes.spines["bottom"].set_color("#e0b84a")
    ejes.spines["left"].set_color("#e0b84a")
    ejes.yaxis.grid(True, linestyle="--", linewidth=0.6, color="#2a4a3e", zorder=0)
    ejes.set_axisbelow(True)
    if maximo <= 0:
        ejes.set_ylim(0, 1)
    else:
        ejes.set_ylim(0, maximo + 1.4)

    indice = 0
    while indice < len(totales):
        ejes.text(
            indice,
            totales[indice],
            str(totales[indice]),
            ha="center",
            va="bottom",
            color="#f4f1ea",
            fontsize=10,
        )
        indice = indice + 1

    figura = ejes.figure
    figura.tight_layout()
    figura.subplots_adjust(left=0.2, right=0.98, top=0.86, bottom=0.18)
    return "Gráfica actualizada"
