CREATE TABLE IF NOT EXISTS EncuestaRespondida (
    id SERIAL PRIMARY KEY,
    encuesta_id INTEGER NOT NULL,
    encuestado_id INTEGER NOT NULL,
    fecha_hora_respuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (encuesta_id) REFERENCES Encuesta(id),
    FOREIGN KEY (encuestado_id) REFERENCES Encuestado(id),
    UNIQUE (encuesta_id, encuestado_id)
);
