-- Ejecutar scripts de creación de tablas en el orden correcto
\i /docker-entrypoint-initdb.d/ddl/Contacto.sql
\i /docker-entrypoint-initdb.d/ddl/Estado.sql
\i /docker-entrypoint-initdb.d/ddl/Solicitante.sql
\i /docker-entrypoint-initdb.d/ddl/Encuesta.sql
\i /docker-entrypoint-initdb.d/ddl/Pregunta.sql
\i /docker-entrypoint-initdb.d/ddl/OpcionRespuesta.sql
\i /docker-entrypoint-initdb.d/ddl/Encuestado.sql
\i /docker-entrypoint-initdb.d/ddl/EncuestaRespondida.sql
\i /docker-entrypoint-initdb.d/ddl/RespuestaSeleccionada.sql
\i /docker-entrypoint-initdb.d/ddl/Persona.sql
\i /docker-entrypoint-initdb.d/ddl/Empresa.sql
\i /docker-entrypoint-initdb.d/ddl/Telefono.sql

-- Insertar datos de prueba
\i /docker-entrypoint-initdb.d/dml/insert_test_data.sql