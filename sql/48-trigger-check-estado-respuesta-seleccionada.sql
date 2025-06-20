CREATE OR REPLACE FUNCTION check_encuesta_estado_en_carga()
RETURNS TRIGGER AS $$
DECLARE
    v_encuesta_id INTEGER;
    v_estado_id INTEGER;
BEGIN
    -- Determinar el id de la encuesta relacionada
    IF TG_OP = 'DELETE' THEN
        SELECT encuesta_id INTO v_encuesta_id
        FROM Pregunta
        WHERE id = OLD.pregunta_id;
    ELSE
        SELECT encuesta_id INTO v_encuesta_id
        FROM Pregunta
        WHERE id = NEW.pregunta_id;
    END IF;

    -- Obtener el estado de la encuesta
    SELECT estado_id INTO v_estado_id
    FROM Encuesta
    WHERE id = v_encuesta_id;

    -- Verificar si el estado es "En carga" (1)
    IF v_estado_id <> 2 THEN
        RAISE EXCEPTION 'No se puede modificar respuestas si la encuesta no está en estado "Abierto"';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_check_estado_respuesta_seleccionada
BEFORE INSERT OR UPDATE OR DELETE ON RespuestaSeleccionada
FOR EACH ROW
EXECUTE FUNCTION check_encuesta_estado_en_carga();