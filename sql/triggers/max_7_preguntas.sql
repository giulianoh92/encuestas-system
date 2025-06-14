CREATE OR REPLACE FUNCTION max_7_preguntas()
RETURNS TRIGGER AS $$
DECLARE
    cantidad INTEGER;
BEGIN
    SELECT COUNT(*) INTO cantidad
    FROM Pregunta
    WHERE encuesta_id = NEW.encuesta_id;

    IF cantidad >= 7 THEN
        RAISE EXCEPTION 'Una encuesta no puede tener más de 7 preguntas.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_max_7_preguntas
BEFORE INSERT ON Pregunta
FOR EACH ROW EXECUTE FUNCTION max_7_preguntas();
