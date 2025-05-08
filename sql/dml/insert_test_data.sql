-- Datos para Persona
INSERT INTO Persona (nombre, apellido, email) VALUES 
('Juan', 'Pérez', 'juan.perez@example.com'),
('Ana', 'Gómez', 'ana.gomez@example.com');

-- Datos para Empresa
INSERT INTO Empresa (razon_social, correo_contacto) VALUES 
('Tech Solutions', 'contacto@techsolutions.com'),
('Innovar S.A.', 'info@innovarsa.com');

-- Datos para Estado
INSERT INTO Estado (nombre_estado) VALUES 
('Activa'),
('Finalizada');

-- Datos para Solicitante
INSERT INTO Solicitante (persona_id, empresa_id) VALUES 
(1, 1),
(2, 2);

-- Datos para Encuesta
INSERT INTO Encuesta (solicitante_id, denominacion, estado_id) VALUES 
(1, 'Satisfacción del cliente', 1),
(2, 'Encuesta interna', 2);

-- Datos para Pregunta
INSERT INTO Pregunta (encuesta_id, texto_pregunta, ponderacion) VALUES 
(1, '¿Cómo calificaría nuestro servicio?', 1.0),
(1, '¿Recomendaría nuestra empresa?', 1.0);

-- Datos para OpcionRespuesta
INSERT INTO OpcionRespuesta (pregunta_id, texto_opcion, ponderacion) VALUES 
(1, 'Excelente', 5.0),
(1, 'Bueno', 4.0),
(1, 'Regular', 3.0),
(1, 'Malo', 2.0),
(1, 'Pésimo', 1.0);

-- Datos para Encuestado
INSERT INTO Encuestado (persona_id, nombre, apellido, genero, correo_contacto, fecha_nacimiento, ocupacion) VALUES 
(1, 'Carlos', 'López', 'Masculino', 'carlos.lopez@example.com', '1990-05-10', 'Ingeniero'),
(2, 'Laura', 'Martínez', 'Femenino', 'laura.martinez@example.com', '1985-08-20', 'Diseñadora');

-- Datos para EncuestaRespondida
INSERT INTO EncuestaRespondida (encuesta_id, encuestado_id) VALUES 
(1, 1),
(1, 2);

-- Datos para RespuestaSeleccionada
INSERT INTO RespuestaSeleccionada (encuesta_respondida_id, pregunta_id, opcion_id) VALUES 
(1, 1, 1),
(1, 2, 2),
(2, 1, 3),
(2, 2, 1);
