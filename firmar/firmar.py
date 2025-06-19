#!/usr/bin/env python3
"""
genera_firma_csv.py  ──
Lee un CSV con el formato usado por cargar_csv_respuestas, calcula la
firma MD5 de las líneas de datos y muestra (o sustituye) el footer.
Uso:
    python genera_firma_csv.py <archivo.csv>  [--reescribir]
"""

import argparse
import hashlib
import pathlib
import sys

def calcular_firma(path: pathlib.Path) -> str:
    """Devuelve la firma (10 hex) exigida por la BD."""
    texto = path.read_text(encoding="utf-8").replace("\r", "")
    lineas = texto.split("\n")
    if len(lineas) < 3:
        raise ValueError("El archivo debe tener al menos header, datos y footer.")
    datos = "\n".join(lineas[1:-1]) + "\n"          # concatena y agrega \n final
    return hashlib.md5(datos.encode()).hexdigest()[:10], len(lineas) - 2

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("csv", type=pathlib.Path)
    ap.add_argument("--reescribir", action="store_true",
                    help="sobreescribe el archivo con el footer correcto")
    args = ap.parse_args()

    firma, cantidad = calcular_firma(args.csv)
    nuevo_footer = f"FIN{cantidad:05d}{firma}"

    if args.reescribir:
        texto = args.csv.read_text(encoding="utf-8").replace("\r", "")
        lineas = texto.split("\n")
        lineas[-1] = nuevo_footer                # reemplaza el footer
        args.csv.write_text("\n".join(lineas), encoding="utf-8")
        print(f"Footer actualizado a: {nuevo_footer}")
    else:
        print(f"Firma calculada : {firma}")
        print(f"Footer esperado : FIN{cantidad:05d}{firma}")

if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        sys.exit(f"Error: {exc}")
