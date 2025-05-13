#!/bin/bash

# Cargar variables de entorno del archivo .env si existe
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Función para mostrar el menú de ayuda
function show_help() {
  echo "Uso: ./manage-services.sh [opción] [--test-data]"
  echo "Opciones:"
  echo "  start                  - Inicia los servicios en segundo plano (modo normal)."
  echo "  start-logs             - Inicia los servicios y muestra los logs (sin -d)."
  echo "  restart                - Reinicia los servicios (sin eliminar volúmenes)."
  echo "  restart-clean          - Reinicia los servicios eliminando volúmenes."
  echo "  rebuild                - Reinicia los servicios con reinstalación de imágenes."
  echo "  stop                   - Detiene los servicios."
  echo "  help                   - Muestra este mensaje de ayuda."
  echo ""
  echo "Flags transversales:"
  echo "  --test-data  - Aplica el esquema DDL y los datos de prueba después de la opción principal."
}

# Esperar a que la base de datos esté lista
function wait_for_db() {
  echo "Esperando a que la base de datos esté lista..."
  for i in {1..20}; do
    docker-compose exec -T db pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" && return 0
    sleep 1
  done
  echo "La base de datos no está lista después de esperar."
  exit 1
}

function apply_test_data() {
  echo "Aplicando datos de prueba..."
  docker-compose exec db psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -f /docker-entrypoint-initdb.d/dml/test_data.sql
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

# Procesar la opción principal y guardar flags adicionales
MAIN_OPTION=""
INIT_SCHEMA_WITH_DATA_FLAG=false

for arg in "$@"; do
  case "$arg" in
    --test-data)
      INIT_SCHEMA_WITH_DATA_FLAG=true
      ;;
    -*)
      # Ignorar otros flags por ahora
      ;;
    *)
      if [ -z "$MAIN_OPTION" ]; then
        MAIN_OPTION="$arg"
      fi
      ;;
  esac
done

if [ -z "$MAIN_OPTION" ]; then
  echo "Error: No se proporcionó ninguna opción."
  show_help
  exit 1
fi

case $MAIN_OPTION in
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
    exit 0
    ;;
  *)
    echo "Opción no válida: $MAIN_OPTION"
    show_help
    exit 1
    ;;
esac

if $INIT_SCHEMA_WITH_DATA_FLAG; then
  wait_for_db
  apply_test_data
fi