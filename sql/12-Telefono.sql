CREATE TABLE IF NOT EXISTS Telefono (
    id SERIAL PRIMARY KEY,
    contacto_id INTEGER NOT NULL,
    numero VARCHAR(20) NOT NULL,
    FOREIGN KEY (contacto_id) REFERENCES Contacto(id)
);
