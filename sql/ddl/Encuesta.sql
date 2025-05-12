CREATE TABLE IF NOT EXISTS Encuesta (
    id SERIAL PRIMARY KEY,
    denominacion VARCHAR(255) NOT NULL,
    fecha_desde DATE NOT NULL,
    fecha_hasta DATE NOT NULL,
    minimo_respuestas INTEGER NOT NULL CHECK (minimo_respuestas > 0),
    estado_id INTEGER NOT NULL,
    solicitante_id INTEGER NOT NULL,
    FOREIGN KEY (estado_id) REFERENCES Estado(id),
    FOREIGN KEY (solicitante_id) REFERENCES Solicitante(id)
);
