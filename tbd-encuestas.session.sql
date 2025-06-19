CALL cargar_csv_respuestas('/csv/respuestas.csv');

SELECT * FROM csv_errores_log ORDER BY id DESC LIMIT 10;
