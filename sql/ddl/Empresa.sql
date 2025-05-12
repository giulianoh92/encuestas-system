CREATE TABLE IF NOT EXISTS Empresa (
    cuit VARCHAR(20) PRIMARY KEY,
    contacto_id INTEGER NOT NULL UNIQUE,
    razon_social VARCHAR(255) NOT NULL CHECK (razon_social = UPPER(razon_social)),
    correo_contacto VARCHAR(100) NOT NULL CHECK (POSITION('@' IN correo_contacto) > 0),
    FOREIGN KEY (contacto_id) REFERENCES Contacto(id)
);
