CREATE TABLE IF NOT EXISTS EncuestaRespondida (
    encuesta_respondida_id SERIAL PRIMARY KEY,
    encuesta_id INTEGER NOT NULL,
    encuestado_id INTEGER NOT NULL,
    fecha_respuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (encuesta_id) REFERENCES Encuesta(encuesta_id),
    FOREIGN KEY (encuestado_id) REFERENCES Encuestado(encuestado_id)
);
