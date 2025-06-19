-- Trigger function para asignar tipo automáticamente
CREATE OR REPLACE FUNCTION asignar_tipo_solicitante()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Persona WHERE contacto_id = NEW.contacto_id) THEN
        NEW.tipo := 'Persona';
    ELSIF EXISTS (SELECT 1 FROM Empresa WHERE contacto_id = NEW.contacto_id) THEN
        NEW.tipo := 'Empresa';
    ELSE
        RAISE EXCEPTION 'El contacto_id % no corresponde a Persona ni Empresa', NEW.contacto_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_asignar_tipo_solicitante
BEFORE INSERT OR UPDATE ON Solicitante
FOR EACH ROW EXECUTE FUNCTION asignar_tipo_solicitante();