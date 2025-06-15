CREATE OR REPLACE FUNCTION validar_contacto_persona()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Empresa WHERE contacto_id = NEW.contacto_id) THEN
        RAISE EXCEPTION 'El contacto_id % ya está asignado a una Empresa', NEW.contacto_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validar_contacto_persona ON Persona;

CREATE TRIGGER trigger_validar_contacto_persona
BEFORE INSERT OR UPDATE ON Persona
FOR EACH ROW EXECUTE FUNCTION validar_contacto_persona();