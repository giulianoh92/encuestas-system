CREATE TABLE IF NOT EXISTS Pregunta (
    pregunta_id SERIAL PRIMARY KEY,
    encuesta_id INTEGER NOT NULL,
    texto_pregunta TEXT NOT NULL,
    ponderacion FLOAT NOT NULL,
    FOREIGN KEY (encuesta_id) REFERENCES Encuesta(encuesta_id)
);
