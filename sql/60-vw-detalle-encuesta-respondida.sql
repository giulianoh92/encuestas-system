CREATE OR REPLACE VIEW vw_detalle_encuesta_respondida AS
SELECT
    er.id AS encuesta_respondida_id,
    e.id AS encuesta_id,
    e.denominacion AS encuesta,
    er.fecha_hora_respuesta,
    enc.id AS encuestado_id,
    enc.nombre AS encuestado_nombre,
    enc.apellido AS encuestado_apellido,
    enc.genero AS encuestado_genero,
    enc.correo AS encuestado_correo,
    enc.fecha_nacimiento AS encuestado_fecha_nacimiento,
    enc.ocupacion AS encuestado_ocupacion,
    p.id AS pregunta_id,
    p.texto AS pregunta_texto,
    o.id AS opcion_respuesta_id,
    o.texto AS opcion_respuesta_texto,
    CASE WHEN rs.id IS NOT NULL THEN TRUE ELSE FALSE END AS es_respuesta_elegida
FROM
    EncuestaRespondida er
    JOIN Encuesta e ON er.encuesta_id = e.id
    JOIN Encuestado enc ON er.encuestado_id = enc.id
    JOIN Pregunta p ON p.encuesta_id = e.id
    JOIN OpcionRespuesta o ON o.pregunta_id = p.id
    LEFT JOIN RespuestaSeleccionada rs
        ON rs.encuesta_respondida_id = er.id
        AND rs.pregunta_id = p.id
        AND rs.opcion_respuesta_id = o.id
ORDER BY
    er.id, p.id, o.id;