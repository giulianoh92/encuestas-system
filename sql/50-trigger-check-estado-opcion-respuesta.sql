-- Trigger para OpcionRespuesta
CREATE OR REPLACE FUNCTION check_encuesta_estado_en_carga_opcionrespuesta()
RETURNS TRIGGER AS $$
DECLARE
    v_pregunta_id INTEGER;
    v_encuesta_id INTEGER;
    v_estado_id INTEGER;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_pregunta_id := OLD.pregunta_id;
    ELSE
        v_pregunta_id := NEW.pregunta_id;
    END IF;

    SELECT encuesta_id INTO v_encuesta_id
    FROM Pregunta
    WHERE id = v_pregunta_id;

    SELECT estado_id INTO v_estado_id
    FROM Encuesta
    WHERE id = v_encuesta_id;

    IF v_estado_id <> 1 THEN
        RAISE EXCEPTION 'No se puede modificar opciones de respuesta si la encuesta no está en estado "En carga"';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_check_estado_opcionrespuesta
BEFORE INSERT OR UPDATE OR DELETE ON OpcionRespuesta
FOR EACH ROW
EXECUTE
FUNCTION check_encuesta_estado_en_carga_opcionrespuesta();