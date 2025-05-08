CREATE TABLE IF NOT EXISTS Empresa (
    empresa_id SERIAL PRIMARY KEY,
    razon_social VARCHAR(100) NOT NULL,
    correo_contacto VARCHAR(255)
);
