CREATE TABLE IF NOT EXISTS Solicitante (
    solicitante_id SERIAL PRIMARY KEY,
    persona_id INTEGER NOT NULL,
    empresa_id INTEGER NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES Persona(persona_id),
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id)
);
