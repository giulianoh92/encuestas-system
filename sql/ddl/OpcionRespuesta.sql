CREATE TABLE IF NOT EXISTS OpcionRespuesta (
    opcion_id SERIAL PRIMARY KEY,
    pregunta_id INTEGER NOT NULL,
    texto_opcion TEXT NOT NULL,
    ponderacion FLOAT NOT NULL,
    FOREIGN KEY (pregunta_id) REFERENCES Pregunta(pregunta_id)
);
