CREATE TABLE IF NOT EXISTS OpcionRespuesta (
    id SERIAL PRIMARY KEY,
    pregunta_id INTEGER NOT NULL,
    texto TEXT NOT NULL,
    ponderacion FLOAT NOT NULL CHECK (ponderacion >= 0 AND ponderacion <= 1),
    FOREIGN KEY (pregunta_id) REFERENCES Pregunta(id),
    CONSTRAINT uq_pregunta_opcion UNIQUE (pregunta_id, id)
);
