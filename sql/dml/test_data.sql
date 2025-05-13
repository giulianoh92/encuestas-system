-- Datos para Contacto
INSERT INTO Contacto DEFAULT VALUES;
INSERT INTO Contacto DEFAULT VALUES;

-- Datos para Persona
INSERT INTO Persona (dni, contacto_id, nombre, apellido, email) VALUES 
('12345678A', 1, 'Juan', 'Pérez', 'juan.perez@example.com'),
('87654321B', 2, 'Ana', 'Gómez', 'ana.gomez@example.com');

-- Datos para Empresa
INSERT INTO Empresa (cuit, contacto_id, razon_social, correo_contacto) VALUES 
('30-12345678-9', 1, 'TECH SOLUTIONS', 'contacto@techsolutions.com'),
('30-87654321-0', 2, 'INNOVAR S.A.', 'info@innovarsa.com');

-- Datos para Telefono
INSERT INTO Telefono (contacto_id, numero) VALUES 
(1, '123456789'),
(2, '987654321');

-- Datos para Estado
INSERT INTO Estado (nombre) VALUES 
('Activa'),
('Finalizada');

-- Datos para Solicitante
INSERT INTO Solicitante (tipo, contacto_id) VALUES 
('Persona', 1),
('Empresa', 2);

-- Datos para Encuesta
INSERT INTO Encuesta (denominacion, fecha_desde, fecha_hasta, minimo_respuestas, estado_id, solicitante_id) VALUES 
('Satisfacción del cliente', '2025-05-01', '2025-05-31', 10, 1, 1),
('Encuesta interna', '2025-06-01', '2025-06-30', 5, 2, 2);

-- Datos para Pregunta
INSERT INTO Pregunta (encuesta_id, texto, ponderacion) VALUES 
(1, '¿Cómo calificaría nuestro servicio?', 1.0),
(1, '¿Recomendaría nuestra empresa?', 1.0);

-- Datos para OpcionRespuesta
INSERT INTO OpcionRespuesta (pregunta_id, texto, ponderacion) VALUES 
(1, 'Excelente', 1.0),
(1, 'Bueno', 0.8),
(1, 'Regular', 0.6),
(1, 'Malo', 0.4),
(1, 'Pésimo', 0.2);

-- Datos para Encuestado
INSERT INTO Encuestado (nombre, apellido, genero, correo, fecha_nacimiento, ocupacion) VALUES 
('Carlos', 'López', 'Masculino', 'carlos.lopez@example.com', '1990-05-10', 'Ingeniero'),
('Laura', 'Martínez', 'Femenino', 'laura.martinez@example.com', '1985-08-20', 'Diseñadora');

-- Datos para EncuestaRespondida
INSERT INTO EncuestaRespondida (encuesta_id, encuestado_id) VALUES 
(1, 1),
(1, 2);

-- Datos para RespuestaSeleccionada
INSERT INTO RespuestaSeleccionada (encuesta_respondida_id, pregunta_id, opcion_respuesta_id) VALUES 
(1, 1, 1),
(1, 2, 2),
(2, 1, 3),
(2, 2, 1);