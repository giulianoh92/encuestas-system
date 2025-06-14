CREATE TABLE csv_encuestas_temp (
    id_encuesta INTEGER NOT NULL,
    id_pregunta INTEGER NOT NULL,
    id_respuesta INTEGER NOT NULL,
    fecha_respuesta DATE NOT NULL,
    id_encuestado INTEGER NOT NULL,
    id_respondida INTEGER NOT NULL
);