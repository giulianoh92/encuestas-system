CREATE TABLE IF NOT EXISTS Persona (
    dni VARCHAR(15) PRIMARY KEY,
    contacto_id INTEGER NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL CHECK (POSITION('@' IN email) > 0),
    FOREIGN KEY (contacto_id) REFERENCES Contacto(id)
);
