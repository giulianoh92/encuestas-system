CREATE OR REPLACE FUNCTION validar_contacto_empresa()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Persona WHERE contacto_id = NEW.contacto_id) THEN
        RAISE EXCEPTION 'El contacto_id % ya está asignado a una Persona', NEW.contacto_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_contacto_empresa
BEFORE INSERT OR UPDATE ON Empresa
FOR EACH ROW EXECUTE FUNCTION validar_contacto_empresa();
