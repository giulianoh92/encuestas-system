-- Trigger para Pregunta
CREATE OR REPLACE FUNCTION check_encuesta_estado_en_carga_pregunta()
RETURNS TRIGGER AS $$
DECLARE
    v_encuesta_id INTEGER;
    v_estado_id INTEGER;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_encuesta_id := OLD.encuesta_id;
    ELSE
        v_encuesta_id := NEW.encuesta_id;
    END IF;

    SELECT estado_id INTO v_estado_id
    FROM Encuesta
    WHERE id = v_encuesta_id;

    IF v_estado_id <> 1 THEN
        RAISE EXCEPTION 'No se puede modificar preguntas si la encuesta no está en estado "En carga"';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_estado_pregunta
BEFORE INSERT OR UPDATE OR DELETE ON Pregunta
FOR EACH ROW
EXECUTE FUNCTION check_encuesta_estado_en_carga_pregunta();
