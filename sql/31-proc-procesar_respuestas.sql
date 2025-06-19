CREATE OR REPLACE PROCEDURE procesar_encuesta(encuesta_id_in INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Cursor que recorre todas las encuestas respondidas para una encuesta específica
    cur_respuestas CURSOR FOR
        SELECT id AS encuesta_respondida_id
        FROM EncuestaRespondida
        WHERE encuesta_id = encuesta_id_in;

    -- Variables acumuladoras para los cálculos
    v_total_peso NUMERIC := 0;          -- Suma total de ponderaciones individuales
    v_cantidad_respuestas INTEGER := 0; -- Número de respuestas consideradas
    v_peso_usuario NUMERIC := 0;        -- Ponderación total de cada usuario

    -- Variables para validación inicial
    v_estado_id INTEGER;
    v_minimo INTEGER;
    v_respuestas INTEGER;

    -- Variable para iterar dentro de bucles
    r record;
BEGIN
    -- Validar que la encuesta esté cerrada y tenga suficientes respuestas
    BEGIN
        -- Obtener el estado actual y el mínimo requerido de respuestas de la encuesta
        SELECT estado_id, minimo_respuestas
        INTO v_estado_id, v_minimo
        FROM Encuesta
        WHERE id = encuesta_id_in;

        -- Si la encuesta no está cerrada (estado_id != 3), se lanza una excepción
        IF v_estado_id != 3 THEN
            RAISE EXCEPTION 'La encuesta debe estar cerrada para ser procesada.';
        END IF;

        -- Verificar si se alcanzó el mínimo de respuestas requeridas
        SELECT COUNT(*) INTO v_respuestas
        FROM EncuestaRespondida
        WHERE encuesta_id = encuesta_id_in;

        IF v_respuestas < v_minimo THEN
            RAISE EXCEPTION 'No se alcanzó el mínimo de respuestas.';
        END IF;
    END;

    -- Procesar las respuestas de cada encuestado
    FOR resp IN cur_respuestas LOOP
        -- Reiniciar el peso de usuario para cada encuesta respondida
        v_peso_usuario := 0;

        -- Iterar sobre cada respuesta seleccionada del usuario y calcular su ponderación
        FOR r IN
            SELECT pr.ponderacion AS ponderacion_pregunta,
                   op.ponderacion AS ponderacion_respuesta
            FROM RespuestaSeleccionada rs
            JOIN OpcionRespuesta op 
                ON op.id = rs.opcion_respuesta_id AND op.pregunta_id = rs.pregunta_id
            JOIN Pregunta pr 
                ON pr.id = rs.pregunta_id
            WHERE rs.encuesta_respondida_id = resp.encuesta_respondida_id
        LOOP
            -- Acumular el producto de ponderación de la pregunta y la opción elegida
            v_peso_usuario := v_peso_usuario + (r.ponderacion_pregunta * r.ponderacion_respuesta);
        END LOOP;

        -- Mostrar la ponderación total de este usuario
        RAISE NOTICE 'Encuesta Respondida ID: % Ponderación total: %', resp.encuesta_respondida_id, v_peso_usuario;

        -- Sumar al total acumulado y contar la respuesta procesada
        v_total_peso := v_total_peso + v_peso_usuario;
        v_cantidad_respuestas := v_cantidad_respuestas + 1;
    END LOOP;

    -- Mostrar el promedio de todas las ponderaciones calculadas
    RAISE NOTICE 'Promedio total de la encuesta: %', ROUND(v_total_peso / v_cantidad_respuestas, 3);

    -- Actualizar el estado de la encuesta a "procesada" (estado_id = 4)
    UPDATE Encuesta
    SET estado_id = 4
    WHERE id = encuesta_id_in;
END;
$$;