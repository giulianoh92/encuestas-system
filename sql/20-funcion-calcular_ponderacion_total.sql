CREATE OR REPLACE FUNCTION calcular_ponderacion_total(p_id_respondida INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC := 0;
BEGIN
    SELECT SUM(p.ponderacion * o.ponderacion)
    INTO v_total
    FROM RespuestaSeleccionada rs
    JOIN OpcionRespuesta o ON rs.opcion_respuesta_id = o.id
    JOIN Pregunta p ON o.pregunta_id = p.id
    WHERE rs.encuesta_respondida_id = p_id_respondida;

    RETURN v_total;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN -1;
END;
$$ LANGUAGE plpgsql;
