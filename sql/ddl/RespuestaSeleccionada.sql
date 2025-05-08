CREATE TABLE IF NOT EXISTS RespuestaSeleccionada (
    respuesta_seleccionada_id SERIAL PRIMARY KEY,
    encuesta_respondida_id INTEGER NOT NULL,
    pregunta_id INTEGER NOT NULL,
    opcion_id INTEGER NOT NULL,
    FOREIGN KEY (encuesta_respondida_id) REFERENCES EncuestaRespondida(encuesta_respondida_id),
    FOREIGN KEY (pregunta_id) REFERENCES Pregunta(pregunta_id),
    FOREIGN KEY (opcion_id) REFERENCES OpcionRespuesta(opcion_id)
);
