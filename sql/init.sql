-- init.sql: Ejecutar DDLs y DMLs en orden

-- 1. Crear las tablas (DDL)
\i ddl/Persona.sql
\i ddl/Empresa.sql
\i ddl/Solicitante.sql
\i ddl/Estado.sql
\i ddl/Encuesta.sql
\i ddl/Pregunta.sql
\i ddl/OpcionRespuesta.sql
\i ddl/Encuestado.sql
\i ddl/EncuestaRespondida.sql
\i ddl/RespuestaSeleccionada.sql

-- 2. Insertar datos iniciales (DML)
\i dml/insert_test_data.sql

-- 3. Vistas, triggers y procedimientos (por implementar)
-- \i views/...
-- \i triggers/...
-- \i procedures/...
