CALL cargar_csv_respuestas('/uploads/respuestas.csv');

CALL procesar_csv_respuestas();

UPDATE Encuesta SET estado_id = 3
WHERE id = 110;

CALL procesar_encuesta(110);

SELECT * FROM csv_errores_log;

SELECT * FROM csv_respuestas;

SELECT * FROM Encuestado;

SELECT * FROM EncuestaRespondida;