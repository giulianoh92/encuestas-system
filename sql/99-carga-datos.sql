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
INSERT INTO Solicitante (contacto_id) VALUES (1);

-- Solicitante tipo Empresa
INSERT INTO Solicitante (contacto_id) VALUES (2);

-- Encuesta
INSERT INTO Encuesta (denominacion, fecha_desde, fecha_hasta, minimo_respuestas, estado_id, solicitante_id)
VALUES (
  'Satisfacción del Cliente', 
  CURRENT_DATE + 15, 
  CURRENT_DATE + 20, 
  1,
  2, -- Estado "Abierta"
  1
);

-- Preguntas
INSERT INTO Pregunta (encuesta_id, texto, ponderacion)
VALUES 
(1, '¿Cómo calificaría nuestro servicio?', 0.5), -- ID = 1
(1, '¿Recomendaría nuestra empresa?', 0.5);      -- ID = 2

-- Opciones para Pregunta 1 (ID=1)
INSERT INTO OpcionRespuesta (pregunta_id, texto, ponderacion)
VALUES 
(1, 'Excelente', 1),          -- ID = 1
(1, 'Bueno', 0.75),           -- ID = 2
(1, 'Regular', 0.5),          -- ID = 3
(1, 'Malo', 0.25);            -- ID = 4

-- Opciones para Pregunta 2 (ID=2)
INSERT INTO OpcionRespuesta (pregunta_id, texto, ponderacion)
VALUES 
(2, 'Sí, sin dudas', 1),         -- ID = 5
(2, 'Probablemente sí', 0.75),   -- ID = 6
(2, 'No lo sé', 0.5),            -- ID = 7
(2, 'Probablemente no', 0.25);   -- ID = 8

-- Encuestados
INSERT INTO Encuestado (nombre, apellido, genero, correo, fecha_nacimiento, ocupacion)
VALUES 
('Ana', 'López', 'Femenino', 'ana.lopez@example.com', '1995-04-20', 'Diseñadora'),  -- ID = 1
('Carlos', 'Gómez', 'Masculino', 'carlos.gomez@example.com', '1988-11-15', 'Ingeniero'), -- ID = 2
('María', 'Fernández', 'Femenino', 'maria.fernandez@example.com', '1992-07-30', 'Abogada'); -- ID = 3