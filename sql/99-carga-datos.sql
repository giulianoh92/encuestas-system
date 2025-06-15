INSERT INTO Estado (nombre) VALUES 
('En carga'),
('Abierta'),
('Cerrada'),
('Procesada'); 

-- Contactos
INSERT INTO Contacto DEFAULT VALUES; -- ID 1
INSERT INTO Contacto DEFAULT VALUES; -- ID 2

-- Persona asociada a contacto_id 1
INSERT INTO Persona (dni, contacto_id, nombre, apellido, email)
VALUES ('12345678', 1, 'Juan', 'Pérez', 'juan@example.com');

-- Empresa asociada a contacto_id 2
INSERT INTO Empresa (cuit, contacto_id, razon_social, correo_contacto)
VALUES ('30-12345678-9', 2, 'ACME S.A.', 'contacto@acme.com');

-- Teléfonos
INSERT INTO Telefono (contacto_id, numero)
VALUES (1, '+541112345678'),
       (2, '+541198765432'),
       (1, '+541112345679');

-- Solicitante tipo Persona
INSERT INTO Solicitante (tipo, contacto_id) VALUES ('Persona', 1);

-- Solicitante tipo Empresa
INSERT INTO Solicitante (tipo, contacto_id) VALUES ('Empresa', 2);

INSERT INTO Encuesta (denominacion, fecha_desde, fecha_hasta, minimo_respuestas, estado_id, solicitante_id)
VALUES (
  'Satisfacción del Cliente', 
  CURRENT_DATE + 15, 
  CURRENT_DATE + 20, 
  1, -- mínimo de respuestas
  1, -- Estado Cerrada
  1  -- Solicitante Persona
);


-- Preguntas
INSERT INTO Pregunta (encuesta_id, texto, ponderacion)
VALUES 
(1, '¿Cómo calificaría nuestro servicio?', 0.5),
(1, '¿Recomendaría nuestra empresa?', 0.5);

-- Opciones para Pregunta 1 (id=1)
INSERT INTO OpcionRespuesta (pregunta_id, texto, ponderacion)
VALUES 
(1, 'Excelente', 1),
(1, 'Bueno', 0.75),
(1, 'Regular', 0.5),
(1, 'Malo', 0.25);

-- Opciones para Pregunta 2 (id=2)
INSERT INTO OpcionRespuesta (pregunta_id, texto, ponderacion)
VALUES 
(2, 'Sí, sin dudas', 1),
(2, 'Probablemente sí', 0.75),
(2, 'No lo sé', 0.5),
(2, 'Probablemente no', 0.25);


INSERT INTO Encuestado (nombre, apellido, genero, correo, fecha_nacimiento, ocupacion)
VALUES ('Ana', 'López', 'Femenino', 'ana.lopez@example.com', '1995-04-20', 'Diseñadora'),
       ('Carlos', 'Gómez', 'Masculino', 'carlos.gomez@example.com', '1988-11-15', 'Ingeniero'),
       ('María', 'Fernández', 'Femenino', 'maria.fernandez@example.com', '1992-07-30', 'Abogada');

INSERT INTO EncuestaRespondida (id, encuesta_id, encuestado_id, fecha_hora_respuesta)
VALUES 
(1, 1, 1, '2023-10-01 10:00:00'),
(2, 1, 2, '2023-10-01 11:00:00'),
(3, 1, 3, '2023-10-01 12:00:00');

INSERT INTO RespuestaSeleccionada (encuesta_respondida_id, opcion_respuesta_id)
VALUES 
(1, 1), -- Ana elige "Excelente" para la primera pregunta
(1, 1), -- Ana elige "Sí, sin dudas" para la segunda pregunta
(2, 2), -- Carlos elige "Bueno" para la primera pregunta
(2, 2), -- Carlos elige "Probablemente sí" para la segunda pregunta
(3, 3), -- María elige "Regular" para la primera pregunta
(3, 3); -- María elige "No lo sé" para la segunda pregunta

-- Cambiar estado de la encuesta a "Cerrada"
UPDATE Encuesta SET estado_id = 3 WHERE id = 1;