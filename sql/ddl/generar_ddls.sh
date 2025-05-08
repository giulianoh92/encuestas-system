#!/bin/bash

# Generar DDL para cada tabla
echo "CREATE TABLE IF NOT EXISTS Persona (
    persona_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);" > Persona.sql

echo "CREATE TABLE IF NOT EXISTS Empresa (
    empresa_id SERIAL PRIMARY KEY,
    razon_social VARCHAR(100) NOT NULL,
    correo_contacto VARCHAR(255)
);" > Empresa.sql

echo "CREATE TABLE IF NOT EXISTS Solicitante (
    solicitante_id SERIAL PRIMARY KEY,
    persona_id INTEGER NOT NULL,
    empresa_id INTEGER NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES Persona(persona_id),
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id)
);" > Solicitante.sql

echo "CREATE TABLE IF NOT EXISTS Estado (
    estado_id SERIAL PRIMARY KEY,
    nombre_estado VARCHAR(50) UNIQUE NOT NULL
);" > Estado.sql

echo "CREATE TABLE IF NOT EXISTS Encuesta (
    encuesta_id SERIAL PRIMARY KEY,
    solicitante_id INTEGER NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_finalizacion TIMESTAMP,
    denominacion VARCHAR(100) NOT NULL,
    estado_id INTEGER NOT NULL,
    FOREIGN KEY (solicitante_id) REFERENCES Solicitante(solicitante_id),
    FOREIGN KEY (estado_id) REFERENCES Estado(estado_id)
);" > Encuesta.sql

echo "CREATE TABLE IF NOT EXISTS Pregunta (
    pregunta_id SERIAL PRIMARY KEY,
    encuesta_id INTEGER NOT NULL,
    texto_pregunta TEXT NOT NULL,
    ponderacion FLOAT NOT NULL,
    FOREIGN KEY (encuesta_id) REFERENCES Encuesta(encuesta_id)
);" > Pregunta.sql

echo "CREATE TABLE IF NOT EXISTS OpcionRespuesta (
    opcion_id SERIAL PRIMARY KEY,
    pregunta_id INTEGER NOT NULL,
    texto_opcion TEXT NOT NULL,
    ponderacion FLOAT NOT NULL,
    FOREIGN KEY (pregunta_id) REFERENCES Pregunta(pregunta_id)
);" > OpcionRespuesta.sql

echo "CREATE TABLE IF NOT EXISTS Encuestado (
    encuestado_id SERIAL PRIMARY KEY,
    persona_id INTEGER NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    genero VARCHAR(10) NOT NULL,
    correo_contacto VARCHAR(255),
    fecha_nacimiento DATE NOT NULL,
    ocupacion VARCHAR(100) NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES Persona(persona_id)
);" > Encuestado.sql

echo "CREATE TABLE IF NOT EXISTS EncuestaRespondida (
    encuesta_respondida_id SERIAL PRIMARY KEY,
    encuesta_id INTEGER NOT NULL,
    encuestado_id INTEGER NOT NULL,
    fecha_respuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (encuesta_id) REFERENCES Encuesta(encuesta_id),
    FOREIGN KEY (encuestado_id) REFERENCES Encuestado(encuestado_id)
);" > EncuestaRespondida.sql

echo "CREATE TABLE IF NOT EXISTS RespuestaSeleccionada (
    respuesta_seleccionada_id SERIAL PRIMARY KEY,
    encuesta_respondida_id INTEGER NOT NULL,
    pregunta_id INTEGER NOT NULL,
    opcion_id INTEGER NOT NULL,
    FOREIGN KEY (encuesta_respondida_id) REFERENCES EncuestaRespondida(encuesta_respondida_id),
    FOREIGN KEY (pregunta_id) REFERENCES Pregunta(pregunta_id),
    FOREIGN KEY (opcion_id) REFERENCES OpcionRespuesta(opcion_id)
);" > RespuestaSeleccionada.sql

echo "Archivos DDL generados en la carpeta ddl_tables."

# Generar archivo para datos de prueba
cat <<EOF > ../dml/insert_test_data.sql
-- Datos para Persona
INSERT INTO Persona (nombre, apellido, email) VALUES 
('Juan', 'Pérez', 'juan.perez@example.com'),
('Ana', 'Gómez', 'ana.gomez@example.com');

-- Datos para Empresa
INSERT INTO Empresa (razon_social, correo_contacto) VALUES 
('Tech Solutions', 'contacto@techsolutions.com'),
('Innovar S.A.', 'info@innovarsa.com');

-- Datos para Estado
INSERT INTO Estado (nombre_estado) VALUES 
('Activa'),
('Finalizada');

-- Datos para Solicitante
INSERT INTO Solicitante (persona_id, empresa_id) VALUES 
(1, 1),
(2, 2);

-- Datos para Encuesta
INSERT INTO Encuesta (solicitante_id, denominacion, estado_id) VALUES 
(1, 'Satisfacción del cliente', 1),
(2, 'Encuesta interna', 2);

-- Datos para Pregunta
INSERT INTO Pregunta (encuesta_id, texto_pregunta, ponderacion) VALUES 
(1, '¿Cómo calificaría nuestro servicio?', 1.0),
(1, '¿Recomendaría nuestra empresa?', 1.0);

-- Datos para OpcionRespuesta
INSERT INTO OpcionRespuesta (pregunta_id, texto_opcion, ponderacion) VALUES 
(1, 'Excelente', 5.0),
(1, 'Bueno', 4.0),
(1, 'Regular', 3.0),
(1, 'Malo', 2.0),
(1, 'Pésimo', 1.0);

-- Datos para Encuestado
INSERT INTO Encuestado (persona_id, nombre, apellido, genero, correo_contacto, fecha_nacimiento, ocupacion) VALUES 
(1, 'Carlos', 'López', 'Masculino', 'carlos.lopez@example.com', '1990-05-10', 'Ingeniero'),
(2, 'Laura', 'Martínez', 'Femenino', 'laura.martinez@example.com', '1985-08-20', 'Diseñadora');

-- Datos para EncuestaRespondida
INSERT INTO EncuestaRespondida (encuesta_id, encuestado_id) VALUES 
(1, 1),
(1, 2);

-- Datos para RespuestaSeleccionada
INSERT INTO RespuestaSeleccionada (encuesta_respondida_id, pregunta_id, opcion_id) VALUES 
(1, 1, 1),
(1, 2, 2),
(2, 1, 3),
(2, 2, 1);
EOF

echo "Archivo insert_test_data.sql generado con datos de prueba."
