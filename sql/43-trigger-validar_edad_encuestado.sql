CREATE OR REPLACE FUNCTION validar_edad_encuestado()
RETURNS TRIGGER AS $$
DECLARE
    edad INTEGER;
BEGIN
    edad := DATE_PART('year', age(CURRENT_DATE, NEW.fecha_nacimiento));
    IF edad < 16 OR edad > 99 THEN
        RAISE EXCEPTION 'El encuestado debe tener entre 16 y 99 años.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_edad_encuestado
BEFORE INSERT OR UPDATE ON Encuestado
FOR EACH ROW EXECUTE FUNCTION validar_edad_encuestado();
