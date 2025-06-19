/****************************************************************************************
* 1. ESTADOS (se fuerza el id para que “Abierta” sea = 2, tal como espera el código)
****************************************************************************************/
INSERT INTO Estado (id, nombre) VALUES
    (1, 'En carga'),
    (2, 'Abierta'),
    (3, 'Cerrada'),
    (4, 'Procesada')
ON CONFLICT (id) DO NOTHING;

/****************************************************************************************
* 2. CONTACTOS, PERSONA ENCUESTADOR (dni/solicitante = 9999)
****************************************************************************************/
-- Contacto para el solicitante-persona
INSERT INTO Contacto (id) VALUES (1)                      ON CONFLICT DO NOTHING;

-- Persona que actuará como ENCUESTADOR (dni = 9999)
INSERT INTO Persona (dni, contacto_id, nombre, apellido, email)
VALUES ('9999', 1, 'Supervisor', 'General', 'encuestador@demo.com')
ON CONFLICT (dni) DO NOTHING;

/****************************************************************************************
* 3. SOLICITANTE = 9999  (el CSV utiliza “9999” como id_encuestador)
*    El trigger asigna automáticamente tipo = 'Persona'.
****************************************************************************************/
INSERT INTO Solicitante (id, contacto_id)
VALUES (9999, 1)
ON CONFLICT (id) DO NOTHING;

/****************************************************************************************
* 4. ENCUESTA id = 15 — debe estar “Abierta” (estado_id = 2) y vinculada al solicitante 9999
*    Cumplimos los triggers de fecha: fecha_desde ≥ 14 y ≤ 45 días; hasta ≤ +10 días.
****************************************************************************************/
INSERT INTO Encuesta (id, denominacion, fecha_desde, fecha_hasta,
                      minimo_respuestas, estado_id, solicitante_id)
VALUES (15,
        'Encuesta de Demostración',
        DATE '2025-07-10',            -- 21 días después de 2025-06-19
        DATE '2025-07-15',            -- dentro de los 10 días siguientes
        1,
        2,                            -- “Abierta”
        9999)
ON CONFLICT (id) DO NOTHING;

/****************************************************************************************
* 5. PREGUNTAS id = 325, 327, 328, 330  (4 preguntas ⇒ < 7, cumple trigger)
*    Se asigna ponderación 0.25 cada una (total 1.00).
****************************************************************************************/
INSERT INTO Pregunta (id, encuesta_id, texto, ponderacion) VALUES
    (325, 15, 'Pregunta P-325', 0.25),
    (327, 15, 'Pregunta P-327', 0.25),
    (328, 15, 'Pregunta P-328', 0.25),
    (330, 15, 'Pregunta P-330', 0.25)
ON CONFLICT (id) DO NOTHING;

/****************************************************************************************
* 6. OPCIONES DE RESPUESTA (12 en total) — exactamente las que aparecen en el CSV
*    Por regla de negocio, para cada pregunta hay **una** opción con ponderación 1.
****************************************************************************************/
-- Pregunta 325
INSERT INTO OpcionRespuesta (id, pregunta_id, texto, ponderacion) VALUES
    (1500, 325, 'P325 – Opción A (ponderación 1)',   1   ),
    (1501, 325, 'P325 – Opción B',                   0.5 ),
    (1503, 325, 'P325 – Opción C',                   0.25)
ON CONFLICT (id) DO NOTHING;

-- Pregunta 327
INSERT INTO OpcionRespuesta (id, pregunta_id, texto, ponderacion) VALUES
    (1505, 327, 'P327 – Opción A',                   0.25),
    (1506, 327, 'P327 – Opción B (ponderación 1)',   1   ),
    (1510, 327, 'P327 – Opción C',                   0.5 )
ON CONFLICT (id) DO NOTHING;

-- Pregunta 328
INSERT INTO OpcionRespuesta (id, pregunta_id, texto, ponderacion) VALUES
    (1511, 328, 'P328 – Opción A',                   0.5 ),
    (1513, 328, 'P328 – Opción B',                   0.25),
    (1518, 328, 'P328 – Opción C (ponderación 1)',   1   )
ON CONFLICT (id) DO NOTHING;

-- Pregunta 330
INSERT INTO OpcionRespuesta (id, pregunta_id, texto, ponderacion) VALUES
    (1519, 330, 'P330 – Opción A',                   0.25),
    (1520, 330, 'P330 – Opción B',                   0.5 ),
    (1521, 330, 'P330 – Opción C (ponderación 1)',   1   )
ON CONFLICT (id) DO NOTHING;

/****************************************************************************************
* 7. ENCUESTADOS — los 10 IDs que aparecen como último segmento en el CSV
****************************************************************************************/
INSERT INTO Encuestado (id, nombre, apellido, genero, correo, fecha_nacimiento, ocupacion) VALUES
    (   5, 'Eva',     'Demo',  'Femenino',  'eva5@demo.com',  '1998-05-01', 'Analista' ),
    (  78, 'Luis',    'Demo',  'Masculino', 'luis78@demo.com','1994-09-15', 'Diseñador'),
    (  85, 'Rosa',    'Demo',  'Femenino',  'rosa85@demo.com','2000-03-10', 'Estudiante'),
    (  91, 'Tomas',   'Demo',  'Masculino', 'tomas91@demo.com','1990-12-20','Ingeniero'),
    (  95, 'Ariel',   'Demo',  'Masculino', 'ariel95@demo.com','1992-07-07','Docente' ),
    (  98, 'Julia',   'Demo',  'Femenino',  'julia98@demo.com','1996-11-03','Abogada' ),
    ( 105, 'Max',     'Demo',  'Masculino', 'max105@demo.com','1987-02-28','Contador' ),
    ( 111, 'Lara',    'Demo',  'Femenino',  'lara111@demo.com','1993-06-12','Arquitecta'),
    ( 155, 'Diego',   'Demo',  'Masculino', 'diego155@demo.com','1989-10-18','Marketing'),
    ( 185, 'Carla',   'Demo',  'Femenino',  'carla185@demo.com','1991-01-25','Finanzas' )
ON CONFLICT (id) DO NOTHING;

/****************************************************************************************
* 8. AJUSTE DE SECUENCIAS (para que los próximos INSERT usen valores siguientes)
****************************************************************************************/
SELECT setval(pg_get_serial_sequence('Contacto','id'),   (SELECT max(id) FROM Contacto));
SELECT setval(pg_get_serial_sequence('Solicitante','id'),(SELECT max(id) FROM Solicitante));
SELECT setval(pg_get_serial_sequence('Encuesta','id'),   (SELECT max(id) FROM Encuesta));
SELECT setval(pg_get_serial_sequence('Pregunta','id'),   (SELECT max(id) FROM Pregunta));
SELECT setval(pg_get_serial_sequence('OpcionRespuesta','id'),(SELECT max(id) FROM OpcionRespuesta));
SELECT setval(pg_get_serial_sequence('Encuestado','id'), (SELECT max(id) FROM Encuestado));
/****************************************************************************************
* LISTO: con estos datos el archivo CSV aportado se cargará sin violar FKs ni triggers.
****************************************************************************************/
