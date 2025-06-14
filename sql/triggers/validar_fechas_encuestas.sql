CREATE OR REPLACE FUNCTION validar_fechas_encuesta()
RETURNS TRIGGER AS $$
DECLARE
    dias_min INTEGER := 14;
    dias_max INTEGER := 45;
BEGIN
    IF NEW.fecha_desde < CURRENT_DATE + dias_min THEN
        RAISE EXCEPTION 'La fecha desde debe ser al menos dentro de 14 días.';
    ELSIF NEW.fecha_desde > CURRENT_DATE + dias_max THEN
        RAISE EXCEPTION 'La fecha desde no puede ser más de 45 días desde hoy.';
    END IF;

    IF NEW.fecha_hasta > NEW.fecha_desde + INTERVAL '10 days' THEN
        RAISE EXCEPTION 'La fecha hasta no puede ser más de 10 días después de fecha desde.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_fechas_encuesta
BEFORE INSERT OR UPDATE ON Encuesta
FOR EACH ROW EXECUTE FUNCTION validar_fechas_encuesta();
