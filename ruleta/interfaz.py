"""Ventana de la ruleta: apuesta, giro, historial y grafica."""

import math as matematicas
import random as azar

import matplotlib

matplotlib.use("TkAgg")

import tkinter
import tkinter.font as fuentes
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg as LienzoDeFigura
from matplotlib.figure import Figure as Figura
from tkinter import messagebox as avisos
from tkinter import ttk as controles

import fichero
import grafica
from modelo import (
    Apuesta,
    colores_casillas,
    numeros_negros,
    numeros_rojos,
    orden_ruleta,
    saldo_inicial,
)

color_fieltro = "#0c3d2e"
color_panel = "#10281f"
color_oro = "#e0b84a"
color_rojo = "#c0392b"
color_negro = "#161616"
color_verde = "#1f8a4c"
color_texto = "#f4f1ea"


def dibujar_ruleta(lienzo, numero_resaltado, fuente_casilla, fuente_centro):
    lienzo.delete("all")
    centro_x = 230
    centro_y = 236
    radio = 188
    radio_texto = 156
    extension = 360.0 / len(orden_ruleta)
    indice = 0
    while indice < len(orden_ruleta):
        numero = orden_ruleta[indice]
        color_casilla = colores_casillas[numero]
        relleno = color_verde
        if color_casilla == "rojo":
            relleno = color_rojo
        if color_casilla == "negro":
            relleno = color_negro
        inicio = 90 - (indice * extension)
        contorno = "#08261d"
        grosor = 1
        if numero == numero_resaltado:
            contorno = color_oro
            grosor = 4
        lienzo.create_arc(
            centro_x - radio,
            centro_y - radio,
            centro_x + radio,
            centro_y + radio,
            start=inicio - extension,
            extent=extension,
            fill=relleno,
            outline=contorno,
            width=grosor,
        )
        angulo = matematicas.radians(inicio - (extension / 2.0))
        texto_x = centro_x + (radio_texto * matematicas.cos(angulo))
        texto_y = centro_y - (radio_texto * matematicas.sin(angulo))
        lienzo.create_text(
            texto_x,
            texto_y,
            text=str(numero),
            fill=color_texto,
            font=fuente_casilla,
        )
        indice = indice + 1

    lienzo.create_oval(
        centro_x - 62,
        centro_y - 62,
        centro_x + 62,
        centro_y + 62,
        fill="#08261d",
        outline=color_oro,
        width=3,
    )
    lienzo.create_polygon(
        centro_x,
        centro_y - radio - 18,
        centro_x - 11,
        centro_y - radio + 4,
        centro_x + 11,
        centro_y - radio + 4,
        fill=color_oro,
        outline=color_oro,
    )
    texto_centro = "Gira"
    detalle_centro = ""
    if numero_resaltado >= 0:
        texto_centro = str(numero_resaltado)
        detalle_centro = "Verde"
        if colores_casillas[numero_resaltado] == "rojo":
            detalle_centro = "Rojo"
        if colores_casillas[numero_resaltado] == "negro":
            detalle_centro = "Negro"
    lienzo.create_text(
        centro_x,
        centro_y - 8,
        text=texto_centro,
        fill=color_texto,
        font=fuente_centro,
    )
    lienzo.create_text(
        centro_x,
        centro_y + 24,
        text=detalle_centro,
        fill=color_oro,
        font=fuente_casilla,
    )


def iniciar():
    ventana = tkinter.Tk()
    ventana.title("Ruleta")
    ventana.geometry("1180x900")
    ventana.minsize(1080, 840)
    ventana.configure(bg=color_fieltro)

    fuente_base = fuentes.nametofont("TkDefaultFont").copy()
    fuente_base.configure(size=11)
    fuente_titulo = fuentes.Font(family=fuente_base.cget("family"), size=22, weight="bold")
    fuente_saldo = fuentes.Font(family=fuente_base.cget("family"), size=26, weight="bold")
    fuente_casilla = fuentes.Font(family=fuente_base.cget("family"), size=8, weight="bold")
    fuente_centro = fuentes.Font(family=fuente_base.cget("family"), size=28, weight="bold")
    fuente_detalle = fuentes.Font(family=fuente_base.cget("family"), size=10)

    estilo = controles.Style()
    estilo.theme_use("clam")
    estilo.configure("TEntry", fieldbackground="#f7f3ea", padding=6, font=fuente_base)
    estilo.configure("TCombobox", fieldbackground="#f7f3ea", padding=4, font=fuente_base)
    estilo.configure(
        "Treeview",
        font=fuente_base,
        rowheight=26,
        background="#f7f3ea",
        fieldbackground="#f7f3ea",
        foreground="#1c2418",
        borderwidth=0,
    )
    estilo.configure(
        "Treeview.Heading",
        font=fuente_base,
        background="#e0b84a",
        foreground="#1c2418",
        relief="flat",
    )
    estilo.map(
        "Treeview",
        background=[("selected", "#d9ebe3")],
        foreground=[("selected", "#1c2418")],
    )

    cabecera = tkinter.Frame(ventana, bg="#08261d")
    cabecera.pack(fill="x")
    tkinter.Label(
        cabecera,
        text="Ruleta",
        bg="#08261d",
        fg=color_oro,
        font=fuente_titulo,
        anchor="w",
    ).pack(fill="x", padx=20, pady=(14, 0))
    tkinter.Label(
        cabecera,
        text="Apuesta al color o al color y su número. El resultado se guarda en historial.txt.",
        bg="#08261d",
        fg="#c9d5cc",
        font=fuente_detalle,
        anchor="w",
    ).pack(fill="x", padx=20, pady=(2, 14))

    etiqueta_estado = tkinter.Label(
        ventana,
        text="Saldo inicial: 100 €. Elige color, escribe la apuesta y gira.",
        bg="#08261d",
        fg=color_texto,
        anchor="w",
        padx=16,
        pady=8,
        font=fuente_base,
    )
    etiqueta_estado.pack(fill="x", side="bottom")

    cuerpo = tkinter.Frame(ventana, bg=color_fieltro)
    cuerpo.pack(fill="both", expand=True, padx=16, pady=12)
    cuerpo.columnconfigure(0, weight=0)
    cuerpo.columnconfigure(1, weight=1)
    cuerpo.rowconfigure(0, weight=0)
    cuerpo.rowconfigure(1, weight=1)

    panel_ruleta = tkinter.Frame(cuerpo, bg=color_fieltro)
    panel_ruleta.grid(row=0, column=0, sticky="n", padx=(0, 12))

    lienzo = tkinter.Canvas(
        panel_ruleta,
        width=460,
        height=470,
        bg=color_fieltro,
        highlightthickness=0,
    )
    lienzo.pack()

    panel_juego = tkinter.Frame(
        cuerpo,
        bg=color_panel,
        highlightbackground=color_oro,
        highlightthickness=1,
    )
    panel_juego.grid(row=0, column=1, sticky="nsew")

    tkinter.Label(
        panel_juego,
        text="Saldo",
        bg=color_panel,
        fg="#c9d5cc",
        font=fuente_detalle,
        anchor="w",
    ).pack(fill="x", padx=16, pady=(12, 0))
    etiqueta_saldo = tkinter.Label(
        panel_juego,
        text="100,00 €",
        bg=color_panel,
        fg=color_oro,
        font=fuente_saldo,
        anchor="w",
    )
    etiqueta_saldo.pack(fill="x", padx=16)

    formulario = tkinter.Frame(panel_juego, bg=color_panel)
    formulario.pack(fill="x", padx=16, pady=(8, 4))
    formulario.columnconfigure(1, weight=1)

    tkinter.Label(
        formulario,
        text="Apuesta",
        bg=color_panel,
        fg=color_texto,
        font=fuente_base,
    ).grid(row=0, column=0, sticky="w", pady=6, padx=(0, 12))
    caja_apuesta = controles.Entry(formulario, font=fuente_base, width=16)
    caja_apuesta.grid(row=0, column=1, sticky="ew", pady=6)
    caja_apuesta.insert(0, "10")

    marco_colores = tkinter.Frame(formulario, bg=color_panel)
    marco_colores.grid(row=1, column=0, columnspan=2, sticky="ew", pady=(4, 6))
    color_elegido = tkinter.StringVar(value="rojo")

    boton_verde = tkinter.Radiobutton(
        marco_colores,
        text="Verde  x10",
        variable=color_elegido,
        value="verde",
        indicatoron=0,
        bg=color_verde,
        fg=color_texto,
        selectcolor=color_verde,
        activebackground=color_verde,
        activeforeground=color_texto,
        font=fuente_base,
        padx=10,
        pady=8,
        relief="flat",
    )
    boton_rojo = tkinter.Radiobutton(
        marco_colores,
        text="Rojo  x2",
        variable=color_elegido,
        value="rojo",
        indicatoron=0,
        bg=color_rojo,
        fg=color_texto,
        selectcolor=color_rojo,
        activebackground=color_rojo,
        activeforeground=color_texto,
        font=fuente_base,
        padx=10,
        pady=8,
        relief="flat",
    )
    boton_negro = tkinter.Radiobutton(
        marco_colores,
        text="Negro  x2",
        variable=color_elegido,
        value="negro",
        indicatoron=0,
        bg=color_negro,
        fg=color_texto,
        selectcolor="#2a2a2a",
        activebackground=color_negro,
        activeforeground=color_texto,
        font=fuente_base,
        padx=10,
        pady=8,
        relief="flat",
    )
    boton_verde.pack(side="left", expand=True, fill="x", padx=(0, 6))
    boton_rojo.pack(side="left", expand=True, fill="x", padx=6)
    boton_negro.pack(side="left", expand=True, fill="x", padx=(6, 0))

    tkinter.Label(
        formulario,
        text="Número",
        bg=color_panel,
        fg=color_texto,
        font=fuente_base,
    ).grid(row=2, column=0, sticky="w", pady=6, padx=(0, 12))
    numero_elegido = tkinter.StringVar(value="Solo color")
    desplegable = controles.Combobox(
        formulario,
        textvariable=numero_elegido,
        state="readonly",
        font=fuente_base,
    )
    desplegable.grid(row=2, column=1, sticky="ew", pady=6)

    etiqueta_premio = tkinter.Label(
        panel_juego,
        text="",
        bg=color_panel,
        fg=color_oro,
        font=fuente_detalle,
        anchor="w",
        justify="left",
    )
    etiqueta_premio.pack(fill="x", padx=16, pady=(0, 6))

    boton_girar = tkinter.Button(
        panel_juego,
        text="Girar",
        bg=color_oro,
        fg="#1c2418",
        activebackground="#c9a33a",
        activeforeground="#1c2418",
        relief="flat",
        font=fuente_titulo,
        cursor="hand2",
        pady=6,
    )
    boton_girar.pack(fill="x", padx=16, pady=(0, 8))

    tkinter.Label(
        panel_juego,
        text="El 0 es el único verde. Si aciertas color y número, el premio del color se multiplica por 3.",
        bg=color_panel,
        fg="#c9d5cc",
        font=fuente_detalle,
        anchor="w",
        justify="left",
        wraplength=460,
    ).pack(fill="x", padx=16, pady=(0, 10))

    marco_grafica = tkinter.Frame(
        cuerpo,
        bg=color_panel,
        highlightbackground=color_oro,
        highlightthickness=1,
    )
    marco_grafica.grid(row=1, column=1, sticky="nsew", pady=(10, 0))
    tkinter.Label(
        marco_grafica,
        text="Gráfica",
        bg=color_panel,
        fg=color_oro,
        font=fuente_base,
        anchor="w",
    ).pack(fill="x", padx=10, pady=(8, 0))
    figura = Figura(figsize=(6.2, 2.7), dpi=100, facecolor=color_panel)
    ejes = figura.add_subplot(111)
    lienzo_figura = LienzoDeFigura(figura, master=marco_grafica)
    panel_dibujo = lienzo_figura.get_tk_widget()
    panel_dibujo.configure(bg=color_panel, highlightthickness=0)
    panel_dibujo.pack(fill="both", expand=True, padx=8, pady=(0, 8))

    marco_lista = tkinter.Frame(cuerpo, bg=color_panel, highlightbackground=color_oro, highlightthickness=1)
    marco_lista.grid(row=1, column=0, sticky="nsew", padx=(0, 12), pady=(10, 0))
    tkinter.Label(
        marco_lista,
        text="Historial",
        bg=color_panel,
        fg=color_oro,
        font=fuente_base,
        anchor="w",
    ).pack(fill="x", padx=10, pady=(8, 0))
    marco_tabla = tkinter.Frame(marco_lista, bg=color_panel)
    marco_tabla.pack(fill="both", expand=True, padx=10, pady=(4, 10))
    marco_tabla.rowconfigure(0, weight=1)
    marco_tabla.columnconfigure(0, weight=1)
    tabla = controles.Treeview(
        marco_tabla,
        columns=("numero", "color", "apuesta", "premio", "saldo"),
        show="headings",
        height=5,
    )
    tabla.heading("numero", text="Número")
    tabla.heading("color", text="Color")
    tabla.heading("apuesta", text="Apuesta")
    tabla.heading("premio", text="Premio")
    tabla.heading("saldo", text="Saldo")
    tabla.column("numero", width=70, anchor="center", stretch=False)
    tabla.column("color", width=80, anchor="w", stretch=False)
    tabla.column("apuesta", width=90, anchor="e", stretch=True)
    tabla.column("premio", width=90, anchor="e", stretch=True)
    tabla.column("saldo", width=90, anchor="e", stretch=True)
    barra_lista = tkinter.Scrollbar(marco_tabla, command=tabla.yview)
    tabla.configure(yscrollcommand=barra_lista.set)
    tabla.grid(row=0, column=0, sticky="nsew")
    barra_lista.grid(row=0, column=1, sticky="ns")

    estado = {"saldo": saldo_inicial}
    giro = {"pasos": 0, "salido": 0, "cantidad": 0.0, "color": "rojo", "numero": ""}

    def escribir_euros(etiqueta, valor):
        etiqueta.configure(text=("%.2f" % valor).replace(".", ",") + " €")

    def actualizar_numeros():
        color = color_elegido.get()
        numeros = ["Solo color"]
        origen = numeros_rojos
        if color == "negro":
            origen = numeros_negros
        if color == "verde":
            origen = [0]
        indice = 0
        while indice < len(origen):
            numeros.append(str(origen[indice]))
            indice = indice + 1
        desplegable.configure(values=numeros)
        numero_elegido.set("Solo color")
        texto_regla = "Solo color: x2. Con el número: x6."
        if color == "verde":
            texto_regla = "Solo color: x10. Con el 0: x30."
        etiqueta_premio.configure(text=texto_regla)
        boton_verde.configure(highlightthickness=2, highlightbackground=color_verde)
        boton_rojo.configure(highlightthickness=2, highlightbackground=color_rojo)
        boton_negro.configure(highlightthickness=2, highlightbackground=color_negro)
        if color == "verde":
            boton_verde.configure(highlightthickness=3, highlightbackground=color_oro)
        if color == "rojo":
            boton_rojo.configure(highlightthickness=3, highlightbackground=color_oro)
        if color == "negro":
            boton_negro.configure(highlightthickness=3, highlightbackground=color_oro)

    def refrescar():
        tiradas = fichero.leer_historial(fichero.ruta_historial)
        estado["saldo"] = saldo_inicial
        if len(tiradas) > 0:
            estado["saldo"] = tiradas[len(tiradas) - 1].saldo
        escribir_euros(etiqueta_saldo, estado["saldo"])
        filas = tabla.get_children()
        for fila in filas:
            tabla.delete(fila)
        indice = 0
        while indice < len(tiradas):
            tirada = tiradas[indice]
            apuesta_texto = ("%.2f" % tirada.cantidad).replace(".", ",") + " €"
            premio_texto = ("%.2f" % tirada.ganancia).replace(".", ",") + " €"
            saldo_texto = ("%.2f" % tirada.saldo).replace(".", ",") + " €"
            nombre_color = "Verde"
            if tirada.color_salido == "rojo":
                nombre_color = "Rojo"
            if tirada.color_salido == "negro":
                nombre_color = "Negro"
            tabla.insert(
                "",
                tkinter.END,
                values=(
                    str(tirada.numero_salido),
                    nombre_color,
                    apuesta_texto,
                    premio_texto,
                    saldo_texto,
                ),
            )
            indice = indice + 1
        filas_tabla = tabla.get_children()
        if len(filas_tabla) > 0:
            tabla.see(filas_tabla[len(filas_tabla) - 1])
        grafica.dibujar_grafica(ejes, tiradas)
        lienzo_figura.draw()

    def animar():
        if giro["pasos"] < 16:
            falso = azar.randint(0, 36)
            dibujar_ruleta(lienzo, falso, fuente_casilla, fuente_centro)
            giro["pasos"] = giro["pasos"] + 1
            ventana.after(70, animar)
        else:
            tirada = Apuesta(
                giro["cantidad"],
                giro["color"],
                giro["numero"],
                giro["salido"],
                estado["saldo"],
            )
            fichero.guardar_tirada(fichero.ruta_historial, tirada)
            dibujar_ruleta(lienzo, tirada.numero_salido, fuente_casilla, fuente_centro)
            refrescar()
            premio = ("%.2f" % tirada.ganancia).replace(".", ",")
            apuesta_texto = ("%.2f" % tirada.cantidad).replace(".", ",")
            nombre_color = "verde"
            if tirada.color_salido == "rojo":
                nombre_color = "rojo"
            if tirada.color_salido == "negro":
                nombre_color = "negro"
            if tirada.ganancia > 0:
                etiqueta_estado.configure(
                    text=(
                        "Ha salido el "
                        + str(tirada.numero_salido)
                        + " "
                        + nombre_color
                        + ". Ganas "
                        + premio
                        + " € (x"
                        + str(tirada.multiplicador)
                        + ")."
                    )
                )
            else:
                etiqueta_estado.configure(
                    text=(
                        "Ha salido el "
                        + str(tirada.numero_salido)
                        + " "
                        + nombre_color
                        + ". Pierdes "
                        + apuesta_texto
                        + " €."
                    )
                )
            boton_girar.configure(state="normal")

    def al_girar():
        texto_cantidad = caja_apuesta.get().strip().replace(",", ".")
        cantidad_valida = texto_cantidad != ""
        cantidad = 0.0
        if cantidad_valida:
            try:
                cantidad = float(texto_cantidad)
            except ValueError:
                cantidad_valida = False
        if not cantidad_valida or cantidad <= 0:
            avisos.showwarning(
                "Apuesta",
                "Escribe una apuesta mayor que 0. Ejemplo: 10 o 2,50",
            )
            etiqueta_estado.configure(text="La apuesta no es válida.")
        elif cantidad > estado["saldo"]:
            avisos.showwarning("Saldo", "No tienes saldo suficiente para esa apuesta.")
            etiqueta_estado.configure(text="Saldo insuficiente.")
        else:
            elegido = ""
            if numero_elegido.get() != "Solo color":
                elegido = numero_elegido.get()
            giro["cantidad"] = cantidad
            giro["color"] = color_elegido.get()
            giro["numero"] = elegido
            giro["salido"] = azar.randint(0, 36)
            giro["pasos"] = 0
            boton_girar.configure(state="disabled")
            etiqueta_estado.configure(text="La bola está girando…")
            animar()

    boton_verde.configure(command=actualizar_numeros)
    boton_rojo.configure(command=actualizar_numeros)
    boton_negro.configure(command=actualizar_numeros)
    boton_girar.configure(command=al_girar)
    actualizar_numeros()
    dibujar_ruleta(lienzo, -1, fuente_casilla, fuente_centro)
    refrescar()
    caja_apuesta.focus_set()
    ventana.mainloop()
    return "Aplicación cerrada"


if __name__ == "__main__":
    iniciar()
