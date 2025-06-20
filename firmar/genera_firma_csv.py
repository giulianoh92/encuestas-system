#!/usr/bin/env python3
"""
genera_firma_csv.py  ──
Lee un CSV con el formato usado por cargar_csv_respuestas (versión 2025-06-19),
calcula la firma MD5 de las líneas de datos **sin** insertar saltos de línea
entre ellas y muestra (o sustituye) el footer.

Uso:
    python genera_firma_csv.py <archivo.csv>  [--reescribir]
"""

import argparse
import hashlib
import pathlib
import sys


def calcular_firma(path: pathlib.Path) -> tuple[str, int]:
    """Devuelve (firma_hex_10, cantidad_lineas_datos) exigida por la BD."""
    texto = path.read_text(encoding="utf-8").replace("\r", "")
    lineas = texto.split("\n")
    if len(lineas) < 3:
        raise ValueError("El archivo debe tener al menos header, datos y footer.")

    # —— NUEVA REGLA: concatenar las líneas de datos sin '\n' ————————
    datos = "".join(lineas[1:-1])               # ← cambiado
    return hashlib.md5(datos.encode()).hexdigest()[:10], len(lineas) - 2


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("csv", type=pathlib.Path)
    ap.add_argument(
        "--reescribir",
        action="store_true",
        help="sobreescribe el archivo con el footer correcto",
    )
    args = ap.parse_args()

    firma, cantidad = calcular_firma(args.csv)
    nuevo_footer = f"FIN{cantidad:05d}{firma}"

    if args.reescribir:
        texto = args.csv.read_text(encoding="utf-8").replace("\r", "")
        lineas = texto.split("\n")
        lineas[-1] = nuevo_footer                          # reemplaza el footer
        args.csv.write_text("\n".join(lineas), encoding="utf-8")
        print(f"Footer actualizado a: {nuevo_footer}")
    else:
        print(f"Firma calculada : {firma}")
        print(f"Footer esperado : {nuevo_footer}")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        sys.exit(f"Error: {exc}")
