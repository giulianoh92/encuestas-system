CREATE TABLE IF NOT EXISTS csv_respuestas (
    id                     SERIAL PRIMARY KEY,
    encuesta_id            INT,
    pregunta_id            INT,
    opcion_respuesta_id    INT,
    fecha_respuesta        DATE,
    encuestador_id         INT,
    encuestado_id          INT,
    ext_encuesta_resp_id   BIGINT,      -- NUEVO: identificador externo de grupo
    linea_original         TEXT NOT NULL,
    fecha_carga              TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(encuestado_id, pregunta_id, opcion_respuesta_id, encuesta_id)
);

-- Claves foráneas y ayudas para la integridad
ALTER TABLE csv_respuestas
    ADD CONSTRAINT fk_csv_encuesta        FOREIGN KEY (encuesta_id)         REFERENCES Encuesta(id),
    ADD CONSTRAINT fk_csv_pregunta        FOREIGN KEY (pregunta_id)         REFERENCES Pregunta(id),
    ADD CONSTRAINT fk_csv_opcion          FOREIGN KEY (opcion_respuesta_id) REFERENCES OpcionRespuesta(id),
    ADD CONSTRAINT fk_csv_respondente     FOREIGN KEY (encuestado_id)       REFERENCES Encuestado(id);

CREATE INDEX IF NOT EXISTS ix_csv_respuestas_encuesta_respondente
    ON csv_respuestas(encuesta_id, encuestado_id);
