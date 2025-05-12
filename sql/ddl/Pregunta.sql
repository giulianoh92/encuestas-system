CREATE TABLE IF NOT EXISTS Pregunta (
    id SERIAL PRIMARY KEY,
    encuesta_id INTEGER NOT NULL,
    texto TEXT NOT NULL,
    ponderacion FLOAT NOT NULL CHECK (ponderacion >= 0 AND ponderacion <= 1),
    FOREIGN KEY (encuesta_id) REFERENCES Encuesta(id)
);
