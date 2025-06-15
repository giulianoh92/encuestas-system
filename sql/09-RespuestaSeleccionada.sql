CREATE TABLE IF NOT EXISTS RespuestaSeleccionada (
    id SERIAL PRIMARY KEY,
    encuesta_respondida_id INTEGER NOT NULL,
    opcion_respuesta_id INTEGER NOT NULL,
    pregunta_id INTEGER NOT NULL,
    
    FOREIGN KEY (encuesta_respondida_id) REFERENCES EncuestaRespondida(id),
    CONSTRAINT fk_opcion_respuesta FOREIGN KEY (opcion_respuesta_id) REFERENCES OpcionRespuesta(id),
    CONSTRAINT fk_pregunta_opcion FOREIGN KEY (pregunta_id, opcion_respuesta_id)
        REFERENCES OpcionRespuesta(pregunta_id, id),
    CONSTRAINT uq_encuesta_respondida_pregunta UNIQUE (encuesta_respondida_id, pregunta_id)
);