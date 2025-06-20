-- Tabla de log general
CREATE TABLE IF NOT EXISTS audit_log_general (
    id SERIAL PRIMARY KEY,
    tabla VARCHAR(100) NOT NULL,
    operacion VARCHAR(10) NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Función genérica para crear logs por tabla
-- (Debes crear una tabla de log y función/trigger por cada tabla)

-- =======================
-- Contacto
-- =======================
CREATE TABLE IF NOT EXISTS audit_log_contacto (
    id SERIAL PRIMARY KEY,
    operacion VARCHAR(10) NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_contacto() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log_contacto (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('INSERT', NULL, row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Contacto', 'INSERT', NULL, row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log_contacto (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Contacto', 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log_contacto (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('DELETE', row_to_json(OLD), NULL, current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Contacto', 'DELETE', row_to_json(OLD), NULL, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_contacto
AFTER INSERT OR UPDATE OR DELETE ON Contacto
FOR EACH ROW EXECUTE FUNCTION audit_contacto();

-- =======================
-- Estado
-- =======================
CREATE TABLE IF NOT EXISTS audit_log_estado (
    id SERIAL PRIMARY KEY,
    operacion VARCHAR(10) NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_estado() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log_estado (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('INSERT', NULL, row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Estado', 'INSERT', NULL, row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log_estado (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Estado', 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log_estado (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('DELETE', row_to_json(OLD), NULL, current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Estado', 'DELETE', row_to_json(OLD), NULL, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_estado
AFTER INSERT OR UPDATE OR DELETE ON Estado
FOR EACH ROW EXECUTE FUNCTION audit_estado();

-- =======================
-- Solicitante
-- =======================
CREATE TABLE IF NOT EXISTS audit_log_solicitante (
    id SERIAL PRIMARY KEY,
    operacion VARCHAR(10) NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_solicitante() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log_solicitante (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('INSERT', NULL, row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Solicitante', 'INSERT', NULL, row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log_solicitante (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Solicitante', 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log_solicitante (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('DELETE', row_to_json(OLD), NULL, current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Solicitante', 'DELETE', row_to_json(OLD), NULL, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_solicitante
AFTER INSERT OR UPDATE OR DELETE ON Solicitante
FOR EACH ROW EXECUTE FUNCTION audit_solicitante();

-- =======================
-- Encuesta
-- =======================
CREATE TABLE IF NOT EXISTS audit_log_encuesta (
    id SERIAL PRIMARY KEY,
    operacion VARCHAR(10) NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_encuesta() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log_encuesta (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('INSERT', NULL, row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Encuesta', 'INSERT', NULL, row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log_encuesta (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Encuesta', 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log_encuesta (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('DELETE', row_to_json(OLD), NULL, current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Encuesta', 'DELETE', row_to_json(OLD), NULL, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_encuesta
AFTER INSERT OR UPDATE OR DELETE ON Encuesta
FOR EACH ROW EXECUTE FUNCTION audit_encuesta();

-- =======================
-- Pregunta
-- =======================
CREATE TABLE IF NOT EXISTS audit_log_pregunta (
    id SERIAL PRIMARY KEY,
    operacion VARCHAR(10) NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_pregunta() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log_pregunta (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('INSERT', NULL, row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Pregunta', 'INSERT', NULL, row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log_pregunta (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Pregunta', 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log_pregunta (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('DELETE', row_to_json(OLD), NULL, current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Pregunta', 'DELETE', row_to_json(OLD), NULL, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_pregunta
AFTER INSERT OR UPDATE OR DELETE ON Pregunta
FOR EACH ROW EXECUTE FUNCTION audit_pregunta();

-- =======================
-- OpcionRespuesta
-- =======================
CREATE TABLE IF NOT EXISTS audit_log_opcionrespuesta (
    id SERIAL PRIMARY KEY,
    operacion VARCHAR(10) NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_opcionrespuesta() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log_opcionrespuesta (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('INSERT', NULL, row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('OpcionRespuesta', 'INSERT', NULL, row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log_opcionrespuesta (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('OpcionRespuesta', 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log_opcionrespuesta (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('DELETE', row_to_json(OLD), NULL, current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('OpcionRespuesta', 'DELETE', row_to_json(OLD), NULL, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_opcionrespuesta
AFTER INSERT OR UPDATE OR DELETE ON OpcionRespuesta
FOR EACH ROW EXECUTE FUNCTION audit_opcionrespuesta();

-- =======================
-- Encuestado
-- =======================
CREATE TABLE IF NOT EXISTS audit_log_encuestado (
    id SERIAL PRIMARY KEY,
    operacion VARCHAR(10) NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_encuestado() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log_encuestado (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('INSERT', NULL, row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Encuestado', 'INSERT', NULL, row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log_encuestado (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Encuestado', 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log_encuestado (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('DELETE', row_to_json(OLD), NULL, current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Encuestado', 'DELETE', row_to_json(OLD), NULL, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_encuestado
AFTER INSERT OR UPDATE OR DELETE ON Encuestado
FOR EACH ROW EXECUTE FUNCTION audit_encuestado();

-- =======================
-- EncuestaRespondida
-- =======================
CREATE TABLE IF NOT EXISTS audit_log_encuestarespondida (
    id SERIAL PRIMARY KEY,
    operacion VARCHAR(10) NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_encuestarespondida() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log_encuestarespondida (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('INSERT', NULL, row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('EncuestaRespondida', 'INSERT', NULL, row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log_encuestarespondida (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('EncuestaRespondida', 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log_encuestarespondida (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('DELETE', row_to_json(OLD), NULL, current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('EncuestaRespondida', 'DELETE', row_to_json(OLD), NULL, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_encuestarespondida
AFTER INSERT OR UPDATE OR DELETE ON EncuestaRespondida
FOR EACH ROW EXECUTE FUNCTION audit_encuestarespondida();

-- =======================
-- RespuestaSeleccionada
-- =======================
CREATE TABLE IF NOT EXISTS audit_log_respuestaseleccionada (
    id SERIAL PRIMARY KEY,
    operacion VARCHAR(10) NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_respuestaseleccionada() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log_respuestaseleccionada (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('INSERT', NULL, row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('RespuestaSeleccionada', 'INSERT', NULL, row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log_respuestaseleccionada (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('RespuestaSeleccionada', 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log_respuestaseleccionada (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('DELETE', row_to_json(OLD), NULL, current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('RespuestaSeleccionada', 'DELETE', row_to_json(OLD), NULL, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_respuestaseleccionada
AFTER INSERT OR UPDATE OR DELETE ON RespuestaSeleccionada
FOR EACH ROW EXECUTE FUNCTION audit_respuestaseleccionada();

-- =======================
-- Persona
-- =======================
CREATE TABLE IF NOT EXISTS audit_log_persona (
    id SERIAL PRIMARY KEY,
    operacion VARCHAR(10) NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_persona() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log_persona (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('INSERT', NULL, row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Persona', 'INSERT', NULL, row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log_persona (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Persona', 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log_persona (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('DELETE', row_to_json(OLD), NULL, current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Persona', 'DELETE', row_to_json(OLD), NULL, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_persona
AFTER INSERT OR UPDATE OR DELETE ON Persona
FOR EACH ROW EXECUTE FUNCTION audit_persona();

-- =======================
-- Empresa
-- =======================
CREATE TABLE IF NOT EXISTS audit_log_empresa (
    id SERIAL PRIMARY KEY,
    operacion VARCHAR(10) NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_empresa() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log_empresa (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('INSERT', NULL, row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Empresa', 'INSERT', NULL, row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log_empresa (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Empresa', 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log_empresa (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('DELETE', row_to_json(OLD), NULL, current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Empresa', 'DELETE', row_to_json(OLD), NULL, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_empresa
AFTER INSERT OR UPDATE OR DELETE ON Empresa
FOR EACH ROW EXECUTE FUNCTION audit_empresa();

-- =======================
-- Telefono
-- =======================
CREATE TABLE IF NOT EXISTS audit_log_telefono (
    id SERIAL PRIMARY KEY,
    operacion VARCHAR(10) NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_telefono() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log_telefono (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('INSERT', NULL, row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Telefono', 'INSERT', NULL, row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log_telefono (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Telefono', 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log_telefono (operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('DELETE', row_to_json(OLD), NULL, current_user);
        INSERT INTO audit_log_general (tabla, operacion, datos_anteriores, datos_nuevos, usuario)
        VALUES ('Telefono', 'DELETE', row_to_json(OLD), NULL, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_audit_telefono
AFTER INSERT OR UPDATE OR DELETE ON Telefono
FOR EACH ROW EXECUTE FUNCTION audit_telefono();
-- =======================