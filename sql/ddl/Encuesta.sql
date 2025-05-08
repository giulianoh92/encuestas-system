CREATE TABLE IF NOT EXISTS Encuesta (
    encuesta_id SERIAL PRIMARY KEY,
    solicitante_id INTEGER NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_finalizacion TIMESTAMP,
    denominacion VARCHAR(100) NOT NULL,
    estado_id INTEGER NOT NULL,
    FOREIGN KEY (solicitante_id) REFERENCES Solicitante(solicitante_id),
    FOREIGN KEY (estado_id) REFERENCES Estado(estado_id)
);
