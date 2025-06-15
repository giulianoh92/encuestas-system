CREATE OR REPLACE VIEW vw_respuestas_por_encuesta AS
SELECT
    er.id AS encuesta_respondida_id,
    e.id AS encuesta_id,
    e.denominacion AS nombre_encuesta,
    enc.id AS encuestado_id,
    enc.nombre,
    enc.apellido,
    enc.genero,
    enc.correo,
    enc.fecha_nacimiento,
    enc.ocupacion,
    er.fecha_hora_respuesta
FROM EncuestaRespondida er
JOIN Encuesta e ON er.encuesta_id = e.id
JOIN Encuestado enc ON er.encuestado_id = enc.id;
