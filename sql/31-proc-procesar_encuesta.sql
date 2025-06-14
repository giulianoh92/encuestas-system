CREATE OR REPLACE PROCEDURE procesar_encuesta(encuesta_id_in INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    cur_respuestas CURSOR FOR
        SELECT id AS encuesta_respondida_id
        FROM EncuestaRespondida
        WHERE encuesta_id = encuesta_id_in;

    v_total_peso NUMERIC := 0;
    v_cantidad_respuestas INTEGER := 0;
    v_peso_usuario NUMERIC := 0;

    v_estado_id INTEGER;
    v_minimo INTEGER;
    v_respuestas INTEGER;
    r record;
BEGIN
    -- Validar estado y mínimo
    BEGIN
        SELECT estado_id, minimo_respuestas
        INTO v_estado_id, v_minimo
        FROM Encuesta
        WHERE id = encuesta_id_in;

        IF v_estado_id != 3 THEN
            RAISE EXCEPTION 'La encuesta debe estar cerrada para ser procesada.';
        END IF;

        SELECT COUNT(*) INTO v_respuestas
        FROM EncuestaRespondida
        WHERE encuesta_id = encuesta_id_in;

        IF v_respuestas < v_minimo THEN
            RAISE EXCEPTION 'No se alcanzó el mínimo de respuestas.';
        END IF;
    END;

    -- Procesar respuestas
    FOR resp IN cur_respuestas LOOP
        v_peso_usuario := 0;

        FOR r IN
            SELECT pr.ponderacion AS ponderacion_pregunta,
                   op.ponderacion AS ponderacion_respuesta
            FROM RespuestaSeleccionada rs
            JOIN OpcionRespuesta op ON op.id = rs.opcion_respuesta_id
            JOIN Pregunta pr ON pr.id = op.pregunta_id
            WHERE rs.encuesta_respondida_id = resp.encuesta_respondida_id
        LOOP
            v_peso_usuario := v_peso_usuario + (r.ponderacion_pregunta * r.ponderacion_respuesta);
        END LOOP;

        RAISE NOTICE 'Encuesta Respondida ID: % Ponderación total: %', resp.encuesta_respondida_id, v_peso_usuario;

        v_total_peso := v_total_peso + v_peso_usuario;
        v_cantidad_respuestas := v_cantidad_respuestas + 1;
    END LOOP;

    RAISE NOTICE 'Promedio total de la encuesta: %', ROUND(v_total_peso / v_cantidad_respuestas, 3);

    -- Cambiar estado
    UPDATE Encuesta
    SET estado_id = 4
    WHERE id = encuesta_id_in;

    COMMIT;
END;
$$;
