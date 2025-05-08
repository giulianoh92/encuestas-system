#!/bin/bash

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

# Construir y levantar los servicios
echo "Levantando los servicios con Docker Compose..."
docker-compose up --build