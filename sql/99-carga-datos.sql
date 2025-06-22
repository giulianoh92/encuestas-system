/****************************************************************************************
* 1. ESTADOS
****************************************************************************************/
INSERT INTO Estado (id, nombre) VALUES
    (1, 'En carga'),
    (2, 'Abierta'),
    (3, 'Cerrada'),
    (4, 'Procesada')
ON CONFLICT (id) DO NOTHING;

/****************************************************************************************
* 2. ENCUESTADOR / SOLICITANTE 9999  (actúa como responsable de la carga)
****************************************************************************************/
-- Contacto para la persona-encuestador
INSERT INTO Contacto (id) VALUES (9999)
ON CONFLICT (id) DO NOTHING;

-- Persona = ENCUESTADOR (dni = 9999)
INSERT INTO Persona (dni, contacto_id, nombre, apellido, email)
VALUES ('9999', 9999, 'Supervisor', 'General', 'encuestador@demo.com')
ON CONFLICT (dni) DO NOTHING;

-- Solicitante 9999 (tipo = 'Persona' lo asigna un trigger)
INSERT INTO Solicitante (id, contacto_id)
VALUES (9999, 9999)
ON CONFLICT (id) DO NOTHING;

/****************************************************************************************
* 3. ENCUESTA 110  ── “SERVICIO DE TELEFONÍA MÓVIL”  (estado: Abierta)
*    Fechas dentro del rango que verifica tu trigger (desde hoy+15 → hoy+25).
****************************************************************************************/
INSERT INTO Encuesta (id, denominacion, fecha_desde, fecha_hasta,
                      minimo_respuestas, estado_id, solicitante_id)
VALUES (110,
        'SERVICIO DE TELEFONÍA MÓVIL',
        CURRENT_DATE + 15,
        CURRENT_DATE + 25,
        1,
        1,          -- En carga
        9999)
ON CONFLICT (id) DO NOTHING;

/****************************************************************************************
* 4. PREGUNTAS  (id 1-5)  — ponderaciones que suman 1,0
****************************************************************************************/
INSERT INTO Pregunta (id, encuesta_id, texto, ponderacion) VALUES
    (1, 110, 'DISPONIBILIDAD DEL SERVICIO',   0.40),
    (2, 110, 'PRECIO COSTO / BENEFICIO',      0.20),
    (3, 110, 'COBERTURA',                     0.15),
    (4, 110, 'ATENCIÓN AL CLIENTE',           0.10),
    (5, 110, 'VARIEDAD DE PLANES',            0.15)
ON CONFLICT (id) DO NOTHING;

/****************************************************************************************
* 5. OPCIONES DE RESPUESTA  (id 10-28)  — una por línea, ponderaciones según tabla
****************************************************************************************/
-- Pregunta 1
INSERT INTO OpcionRespuesta (id, pregunta_id, texto, ponderacion) VALUES
    (10, 1, 'EN TODO MOMENTO',   1.0),
    (11, 1, 'ALGUNOS CORTES',    0.6),
    (12, 1, 'MUCHOS CORTES',     0.2)
ON CONFLICT (id) DO NOTHING;

-- Pregunta 2
INSERT INTO OpcionRespuesta (id, pregunta_id, texto, ponderacion) VALUES
    (13, 2, 'EXCELENTE',         1.0),
    (14, 2, 'MUY BUENO',         0.7),
    (15, 2, 'BUENO',             0.5),
    (16, 2, 'REGULAR',           0.3),
    (17, 2, 'MALO',              0.1)
ON CONFLICT (id) DO NOTHING;

-- Pregunta 3
INSERT INTO OpcionRespuesta (id, pregunta_id, texto, ponderacion) VALUES
    (18, 3, 'MUY BUENA',         1.0),
    (19, 3, 'BUENA',             0.6),
    (20, 3, 'MALA',              0.2)
ON CONFLICT (id) DO NOTHING;

-- Pregunta 4
INSERT INTO OpcionRespuesta (id, pregunta_id, texto, ponderacion) VALUES
    (21, 4, 'EXCELENTE',         1.0),
    (22, 4, 'BUENA',             0.6),
    (23, 4, 'MALA',              0.2)
ON CONFLICT (id) DO NOTHING;

-- Pregunta 5
INSERT INTO OpcionRespuesta (id, pregunta_id, texto, ponderacion) VALUES
    (24, 5, 'PARA TODOS LOS GUSTOS', 1.0),
    (25, 5, 'MUY BUENA VARIEDAD',    0.7),
    (26, 5, 'VARIEDAD ACEPTABLE',    0.5),
    (27, 5, 'POCA VARIEDAD',         0.3),
    (28, 5, 'INSUFICIENTE',          0.1)
ON CONFLICT (id) DO NOTHING;

UPDATE Encuesta
SET estado_id = 2 -- Abierta
WHERE id = 110; 

/****************************************************************************************
* 6. 500 ENCUESTADOS  (id 100-599) — datos dummy; solo se necesita la PK
****************************************************************************************/
DO $$
DECLARE
    v_id INT;
BEGIN
    FOR v_id IN 100..599 LOOP
        INSERT INTO Encuestado (
            id, nombre, apellido, genero, correo,
            fecha_nacimiento, ocupacion)
        VALUES (
            v_id,
            'Nombre_'   || v_id,
            'Apellido_' || v_id,
            CASE WHEN v_id % 2 = 0 THEN 'Masculino' ELSE 'Femenino' END,
            'user' || v_id || '@demo.com',
            '1990-01-01',                       -- fecha ficticia
            'Demo'
        )
        ON CONFLICT (id) DO NOTHING;
    END LOOP;
END $$;

/****************************************************************************************
* 7. AJUSTE DE SECUENCIAS  (para que los próximos INSERT sigan en orden)
****************************************************************************************/
SELECT setval(pg_get_serial_sequence('Contacto',       'id'), (SELECT max(id) FROM Contacto));
SELECT setval(pg_get_serial_sequence('Solicitante',    'id'), (SELECT max(id) FROM Solicitante));
SELECT setval(pg_get_serial_sequence('Encuesta',       'id'), (SELECT max(id) FROM Encuesta));
SELECT setval(pg_get_serial_sequence('Pregunta',       'id'), (SELECT max(id) FROM Pregunta));
SELECT setval(pg_get_serial_sequence('OpcionRespuesta','id'), (SELECT max(id) FROM OpcionRespuesta));
SELECT setval(pg_get_serial_sequence('Encuestado',     'id'), (SELECT max(id) FROM Encuestado));


UPDATE Encuesta
SET estado_id = 2  -- Abierta
WHERE id = 110;