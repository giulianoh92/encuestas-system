CREATE TABLE IF NOT EXISTS RespuestaSeleccionada (
    id SERIAL PRIMARY KEY,
    encuesta_respondida_id INTEGER NOT NULL,
    pregunta_id INTEGER NOT NULL,
    opcion_respuesta_id INTEGER NOT NULL,
    FOREIGN KEY (encuesta_respondida_id) REFERENCES EncuestaRespondida(id),
    FOREIGN KEY (pregunta_id) REFERENCES Pregunta(id),
    FOREIGN KEY (opcion_respuesta_id) REFERENCES OpcionRespuesta(id)
);
