"""Ventana para anotar gastos, guardarlos y ver la grafica."""

import matplotlib

matplotlib.use("TkAgg")

import tkinter
from datetime import date as fecha_de_hoy
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg as LienzoDeFigura
from matplotlib.figure import Figure as Figura
from tkinter import messagebox as avisos
from tkinter import ttk as controles
import tkinter.font as fuentes

import fichero
import grafica
from modelo import Gasto


def iniciar():
    ventana = tkinter.Tk()
    ventana.title("Registro de gastos")
    ventana.geometry("1180x720")
    ventana.minsize(1040, 640)
    ventana.configure(bg="#e7efe9")

    fuente_base = fuentes.nametofont("TkDefaultFont").copy()
    fuente_base.configure(size=11)
    fuente_titulo = fuentes.Font(family=fuente_base.cget("family"), size=20, weight="bold")
    fuente_detalle = fuentes.Font(family=fuente_base.cget("family"), size=10)

    estilo = controles.Style()
    estilo.theme_use("clam")
    estilo.configure(
        "TEntry",
        fieldbackground="#ffffff",
        padding=6,
        font=fuente_base,
    )
    estilo.configure(
        "TCombobox",
        fieldbackground="#ffffff",
        padding=4,
        font=fuente_base,
    )
    estilo.configure(
        "Treeview",
        font=fuente_base,
        rowheight=28,
        background="#ffffff",
        fieldbackground="#ffffff",
        foreground="#24312c",
        borderwidth=0,
    )
    estilo.configure(
        "Treeview.Heading",
        font=fuente_base,
        background="#e7efe9",
        foreground="#1e3a34",
        relief="flat",
    )
    estilo.map(
        "Treeview",
        background=[("selected", "#d9ebe3")],
        foreground=[("selected", "#1e3a34")],
    )

    cabecera = tkinter.Frame(ventana, bg="#1e3a34")
    cabecera.pack(fill="x")
    tkinter.Label(
        cabecera,
        text="Registro de gastos",
        bg="#1e3a34",
        fg="#f4f7f5",
        font=fuente_titulo,
        anchor="w",
    ).pack(fill="x", padx=20, pady=(16, 0))
    tkinter.Label(
        cabecera,
        text="El apunte se guarda en gastos.txt y la gráfica se actualiza al momento.",
        bg="#1e3a34",
        fg="#c5d5ce",
        font=fuente_detalle,
        anchor="w",
    ).pack(fill="x", padx=20, pady=(2, 16))

    etiqueta_estado = tkinter.Label(
        ventana,
        text="Listo.",
        bg="#dfe8e3",
        fg="#1e3a34",
        anchor="w",
        padx=16,
        pady=8,
        font=fuente_base,
    )
    etiqueta_estado.pack(fill="x", side="bottom")

    cuerpo = tkinter.Frame(ventana, bg="#e7efe9")
    cuerpo.pack(fill="both", expand=True, padx=16, pady=16)
    cuerpo.columnconfigure(0, weight=6, minsize=520)
    cuerpo.columnconfigure(1, weight=5, minsize=500)
    cuerpo.rowconfigure(0, weight=1)

    panel_datos = tkinter.Frame(
        cuerpo,
        bg="#fffdf8",
        highlightbackground="#d5ddd8",
        highlightthickness=1,
    )
    panel_datos.grid(row=0, column=0, sticky="nsew", padx=(0, 10))

    panel_grafica = tkinter.Frame(
        cuerpo,
        bg="#fffdf8",
        highlightbackground="#d5ddd8",
        highlightthickness=1,
    )
    panel_grafica.grid(row=0, column=1, sticky="nsew", padx=(10, 0))

    tkinter.Label(
        panel_datos,
        text="Nuevo gasto",
        bg="#fffdf8",
        fg="#1e3a34",
        font=fuente_titulo,
        anchor="w",
    ).pack(fill="x", padx=16, pady=(14, 4))

    formulario = tkinter.Frame(panel_datos, bg="#fffdf8")
    formulario.pack(fill="x", padx=16, pady=(0, 8))
    formulario.columnconfigure(1, weight=1)

    hoy = fecha_de_hoy.today()
    texto_hoy = hoy.strftime("%d/%m/%Y")
    categorias = ["comida", "transporte", "ocio", "otros"]
    categoria_elegida = tkinter.StringVar(value="comida")

    tkinter.Label(
        formulario, text="Fecha", bg="#fffdf8", fg="#3c4a44", font=fuente_base, anchor="w"
    ).grid(row=0, column=0, sticky="w", pady=6, padx=(0, 12))
    caja_fecha = controles.Entry(formulario, font=fuente_base)
    caja_fecha.grid(row=0, column=1, sticky="ew", pady=6)
    caja_fecha.insert(0, texto_hoy)

    tkinter.Label(
        formulario, text="Concepto", bg="#fffdf8", fg="#3c4a44", font=fuente_base, anchor="w"
    ).grid(row=1, column=0, sticky="w", pady=6, padx=(0, 12))
    caja_concepto = controles.Entry(formulario, font=fuente_base)
    caja_concepto.grid(row=1, column=1, sticky="ew", pady=6)

    tkinter.Label(
        formulario, text="Importe", bg="#fffdf8", fg="#3c4a44", font=fuente_base, anchor="w"
    ).grid(row=2, column=0, sticky="w", pady=6, padx=(0, 12))
    caja_importe = controles.Entry(formulario, font=fuente_base)
    caja_importe.grid(row=2, column=1, sticky="ew", pady=6)

    tkinter.Label(
        formulario, text="Categoría", bg="#fffdf8", fg="#3c4a44", font=fuente_base, anchor="w"
    ).grid(row=3, column=0, sticky="w", pady=6, padx=(0, 12))
    desplegable = controles.Combobox(
        formulario,
        textvariable=categoria_elegida,
        values=categorias,
        state="readonly",
        font=fuente_base,
    )
    desplegable.grid(row=3, column=1, sticky="ew", pady=6)

    boton_anadir = tkinter.Button(
        formulario,
        text="Añadir gasto",
        bg="#1e3a34",
        fg="#ffffff",
        activebackground="#163029",
        activeforeground="#ffffff",
        relief="flat",
        padx=12,
        pady=8,
        font=fuente_base,
        cursor="hand2",
    )
    boton_anadir.grid(row=4, column=0, columnspan=2, sticky="ew", pady=(10, 4))

    tkinter.Label(
        panel_datos,
        text="Gastos guardados",
        bg="#fffdf8",
        fg="#1e3a34",
        font=fuente_titulo,
        anchor="w",
    ).pack(fill="x", padx=16, pady=(12, 4))

    marco_lista = tkinter.Frame(panel_datos, bg="#fffdf8")
    marco_lista.pack(fill="both", expand=True, padx=16, pady=(0, 16))
    marco_lista.rowconfigure(0, weight=1)
    marco_lista.columnconfigure(0, weight=1)
    tabla = controles.Treeview(
        marco_lista,
        columns=("fecha", "concepto", "importe", "categoria"),
        show="headings",
        height=10,
    )
    tabla.heading("fecha", text="Fecha")
    tabla.heading("concepto", text="Concepto")
    tabla.heading("importe", text="Importe")
    tabla.heading("categoria", text="Categoría")
    tabla.column("fecha", width=110, minwidth=90, anchor="w", stretch=False)
    tabla.column("concepto", width=160, minwidth=100, anchor="w", stretch=True)
    tabla.column("importe", width=90, minwidth=70, anchor="e", stretch=False)
    tabla.column("categoria", width=110, minwidth=90, anchor="w", stretch=False)
    barra_lista = tkinter.Scrollbar(marco_lista, command=tabla.yview)
    tabla.configure(yscrollcommand=barra_lista.set)
    tabla.grid(row=0, column=0, sticky="nsew")
    barra_lista.grid(row=0, column=1, sticky="ns")

    tkinter.Label(
        panel_grafica,
        text="Gráfica",
        bg="#fffdf8",
        fg="#1e3a34",
        font=fuente_titulo,
        anchor="w",
    ).pack(fill="x", padx=16, pady=(14, 0))

    figura = Figura(figsize=(5.15, 4.7), dpi=100, facecolor="#fffdf8")
    ejes = figura.add_subplot(111)
    lienzo_figura = LienzoDeFigura(figura, master=panel_grafica)
    panel_dibujo = lienzo_figura.get_tk_widget()
    panel_dibujo.configure(bg="#fffdf8", highlightthickness=0)
    panel_dibujo.pack(fill="both", expand=True, padx=8, pady=(0, 8))

    def refrescar():
        gastos = fichero.leer_gastos(fichero.ruta_gastos)
        filas = tabla.get_children()
        for fila in filas:
            tabla.delete(fila)
        indice = 0
        while indice < len(gastos):
            gasto = gastos[indice]
            texto_importe = ("%.2f" % gasto.importe).replace(".", ",") + " €"
            tabla.insert(
                "",
                tkinter.END,
                values=(gasto.fecha, gasto.concepto, texto_importe, gasto.categoria),
            )
            indice = indice + 1
        filas_tabla = tabla.get_children()
        if len(filas_tabla) > 0:
            tabla.see(filas_tabla[len(filas_tabla) - 1])
        grafica.dibujar_grafica(ejes, gastos)
        lienzo_figura.draw()
        etiqueta_estado.configure(
            text="Hay " + str(len(gastos)) + " gastos guardados en gastos.txt."
        )

    def al_anadir():
        fecha = caja_fecha.get().strip()
        concepto = caja_concepto.get().strip().replace(";", ",")
        texto_importe = caja_importe.get().strip().replace(",", ".")
        categoria = categoria_elegida.get().strip()
        importe_valido = texto_importe != ""
        importe = 0.0
        if importe_valido:
            try:
                importe = float(texto_importe)
            except ValueError:
                importe_valido = False
        if fecha == "" or concepto == "" or categoria == "":
            avisos.showwarning(
                "Datos incompletos",
                "Rellena la fecha, el concepto, el importe y la categoría.",
            )
            etiqueta_estado.configure(text="Faltan datos del gasto.")
        elif not importe_valido:
            avisos.showwarning(
                "Importe",
                "El importe tiene que ser un número. Ejemplo: 4,50",
            )
            etiqueta_estado.configure(text="El importe no es válido.")
        elif importe < 0:
            avisos.showwarning("Importe", "El importe no puede ser negativo.")
            etiqueta_estado.configure(text="El importe no puede ser negativo.")
        else:
            gasto = Gasto(fecha, concepto, importe, categoria)
            fichero.guardar_gasto(fichero.ruta_gastos, gasto)
            caja_concepto.delete(0, tkinter.END)
            caja_importe.delete(0, tkinter.END)
            refrescar()
            etiqueta_estado.configure(text="Gasto guardado en el fichero gastos.txt.")

    boton_anadir.configure(command=al_anadir)
    caja_concepto.focus_set()
    refrescar()
    ventana.mainloop()
    return "Aplicación cerrada"


if __name__ == "__main__":
    iniciar()
