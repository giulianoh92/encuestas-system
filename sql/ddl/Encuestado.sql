CREATE TABLE IF NOT EXISTS Encuestado (
    encuestado_id SERIAL PRIMARY KEY,
    persona_id INTEGER NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    genero VARCHAR(10) NOT NULL,
    correo_contacto VARCHAR(255),
    fecha_nacimiento DATE NOT NULL,
    ocupacion VARCHAR(100) NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES Persona(persona_id)
);
