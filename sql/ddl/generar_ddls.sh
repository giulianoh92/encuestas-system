#!/bin/bash

# Generar DDL para cada tabla
echo "CREATE TABLE IF NOT EXISTS Contacto (
    id SERIAL PRIMARY KEY
);" > Contacto.sql

echo "CREATE TABLE IF NOT EXISTS Persona (
    dni VARCHAR(15) PRIMARY KEY,
    contacto_id INTEGER NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL CHECK (POSITION('@' IN email) > 0),
    FOREIGN KEY (contacto_id) REFERENCES Contacto(id)
);" > Persona.sql

echo "CREATE TABLE IF NOT EXISTS Empresa (
    cuit VARCHAR(20) PRIMARY KEY,
    contacto_id INTEGER NOT NULL UNIQUE,
    razon_social VARCHAR(255) NOT NULL CHECK (razon_social = UPPER(razon_social)),
    correo_contacto VARCHAR(100) NOT NULL CHECK (POSITION('@' IN correo_contacto) > 0),
    FOREIGN KEY (contacto_id) REFERENCES Contacto(id)
);" > Empresa.sql

echo "CREATE TABLE IF NOT EXISTS Telefono (
    id SERIAL PRIMARY KEY,
    contacto_id INTEGER NOT NULL,
    numero VARCHAR(20) NOT NULL,
    FOREIGN KEY (contacto_id) REFERENCES Contacto(id)
);" > Telefono.sql

echo "CREATE TABLE IF NOT EXISTS Solicitante (
    id SERIAL PRIMARY KEY,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Persona', 'Empresa')),
    contacto_id INTEGER NOT NULL,
    FOREIGN KEY (contacto_id) REFERENCES Contacto(id)
);" > Solicitante.sql

echo "CREATE TABLE IF NOT EXISTS Estado (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);" > Estado.sql

echo "CREATE TABLE IF NOT EXISTS Encuesta (
    id SERIAL PRIMARY KEY,
    denominacion VARCHAR(255) NOT NULL,
    fecha_desde DATE NOT NULL,
    fecha_hasta DATE NOT NULL,
    minimo_respuestas INTEGER NOT NULL CHECK (minimo_respuestas > 0),
    estado_id INTEGER NOT NULL,
    solicitante_id INTEGER NOT NULL,
    FOREIGN KEY (estado_id) REFERENCES Estado(id),
    FOREIGN KEY (solicitante_id) REFERENCES Solicitante(id)
);" > Encuesta.sql

echo "CREATE TABLE IF NOT EXISTS Pregunta (
    id SERIAL PRIMARY KEY,
    encuesta_id INTEGER NOT NULL,
    texto TEXT NOT NULL,
    ponderacion FLOAT NOT NULL CHECK (ponderacion >= 0 AND ponderacion <= 1),
    FOREIGN KEY (encuesta_id) REFERENCES Encuesta(id)
);" > Pregunta.sql

echo "CREATE TABLE IF NOT EXISTS OpcionRespuesta (
    id SERIAL PRIMARY KEY,
    pregunta_id INTEGER NOT NULL,
    texto TEXT NOT NULL,
    ponderacion FLOAT NOT NULL CHECK (ponderacion >= 0 AND ponderacion <= 1),
    FOREIGN KEY (pregunta_id) REFERENCES Pregunta(id)
);" > OpcionRespuesta.sql

echo "CREATE TABLE IF NOT EXISTS Encuestado (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    genero VARCHAR(20) NOT NULL,
    correo VARCHAR(100) NOT NULL CHECK (POSITION('@' IN correo) > 0),
    fecha_nacimiento DATE NOT NULL CHECK (DATE_PART('year', AGE(fecha_nacimiento)) BETWEEN 16 AND 99),
    ocupacion VARCHAR(100) NOT NULL
);" > Encuestado.sql

echo "CREATE TABLE IF NOT EXISTS EncuestaRespondida (
    id SERIAL PRIMARY KEY,
    encuesta_id INTEGER NOT NULL,
    encuestado_id INTEGER NOT NULL,
    fecha_hora_respuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (encuesta_id) REFERENCES Encuesta(id),
    FOREIGN KEY (encuestado_id) REFERENCES Encuestado(id)
);" > EncuestaRespondida.sql

echo "CREATE TABLE IF NOT EXISTS RespuestaSeleccionada (
    id SERIAL PRIMARY KEY,
    encuesta_respondida_id INTEGER NOT NULL,
    pregunta_id INTEGER NOT NULL,
    opcion_respuesta_id INTEGER NOT NULL,
    FOREIGN KEY (encuesta_respondida_id) REFERENCES EncuestaRespondida(id),
    FOREIGN KEY (pregunta_id) REFERENCES Pregunta(id),
    FOREIGN KEY (opcion_respuesta_id) REFERENCES OpcionRespuesta(id)
);" > RespuestaSeleccionada.sql

echo "Archivos DDL generados en la carpeta ddl_tables."