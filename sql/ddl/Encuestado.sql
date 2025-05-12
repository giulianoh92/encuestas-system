CREATE TABLE IF NOT EXISTS Encuestado (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    genero VARCHAR(20) NOT NULL,
    correo VARCHAR(100) NOT NULL CHECK (POSITION('@' IN correo) > 0),
    fecha_nacimiento DATE NOT NULL CHECK (DATE_PART('year', AGE(fecha_nacimiento)) BETWEEN 16 AND 99),
    ocupacion VARCHAR(100) NOT NULL
);
