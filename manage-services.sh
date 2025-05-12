#!/bin/bash

# Función para mostrar el menú de ayuda
function show_help() {
  echo "Uso: ./manage-services.sh [opción]"
  echo "Opciones:"
  echo "  start          - Inicia los servicios en segundo plano (modo normal)."
  echo "  start-logs     - Inicia los servicios y muestra los logs (sin -d)."
  echo "  restart        - Reinicia los servicios (sin eliminar volúmenes)."
  echo "  restart-clean  - Reinicia los servicios eliminando volúmenes."
  echo "  rebuild        - Reinicia los servicios con reinstalación de imágenes."
  echo "  stop           - Detiene los servicios."
  echo "  help           - Muestra este mensaje de ayuda."
}

# Verificar si Docker está instalado
if ! [ -x "$(command -v docker)" ]; then
  echo "Docker no está instalado. Instalándolo..."
  sudo apt update && sudo apt install -y docker.io
fi

# Verificar si Docker Compose está instalado
if ! [ -x "$(command -v docker-compose)" ]; then
  echo "Docker Compose no está instalado. Instalándolo..."
  sudo apt update && sudo apt install -y docker-compose
fi

# Verificar si se pasó una opción
if [ $# -eq 0 ]; then
  echo "Error: No se proporcionó ninguna opción."
  show_help
  exit 1
fi

# Procesar la opción proporcionada
case $1 in
  start)
    echo "Iniciando los servicios en segundo plano..."
    docker-compose up --build -d
    ;;
  start-logs)
    echo "Iniciando los servicios con logs..."
    docker-compose up --build
    ;;
  restart)
    echo "Reiniciando los servicios..."
    docker-compose down
    docker-compose up --build -d
    ;;
  restart-clean)
    echo "Reiniciando los servicios y eliminando volúmenes..."
    docker-compose down -v
    docker-compose up --build -d
    ;;
  rebuild)
    echo "Reiniciando los servicios con reinstalación de imágenes..."
    docker-compose down
    docker-compose pull
    docker-compose up --build -d
    ;;
  stop)
    echo "Deteniendo los servicios..."
    docker-compose down
    ;;
  help)
    show_help
    ;;
  *)
    echo "Opción no válida: $1"
    show_help
    exit 1
    ;;
esac