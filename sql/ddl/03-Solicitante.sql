CREATE TABLE IF NOT EXISTS Solicitante (
    id SERIAL PRIMARY KEY,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Persona', 'Empresa')),
    contacto_id INTEGER NOT NULL,
    FOREIGN KEY (contacto_id) REFERENCES Contacto(id)
);
