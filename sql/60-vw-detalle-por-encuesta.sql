CREATE OR REPLACE VIEW vw_detalle_por_encuesta AS
SELECT
    er.fecha_hora_respuesta,
    e.denominacion AS encuesta_denominacion,

    ec.nombre AS encuestado_nombre,
    ec.apellido AS encuestado_apellido,
    ec.genero AS encuestado_genero,
    ec.correo AS encuestado_correo,
    ec.ocupacion AS encuestado_ocupacion,
    ec.fecha_nacimiento AS encuestado_fecha_nacimiento,
    
    p.texto AS pregunta_texto,

    orp.texto AS opcion_respuesta_texto

FROM EncuestaRespondida er
JOIN Encuesta e ON er.encuesta_id = e.id
JOIN Encuestado ec ON er.encuestado_id = ec.id

JOIN RespuestaSeleccionada rs ON rs.encuesta_respondida_id = er.id
JOIN Pregunta p ON rs.pregunta_id = p.id
JOIN OpcionRespuesta orp ON rs.opcion_respuesta_id = orp.id AND rs.pregunta_id = orp.pregunta_id;



SELECT * FROM vw_detalle_por_encuesta;

DROP VIEW IF EXISTS vw_detalle_por_encuesta;
