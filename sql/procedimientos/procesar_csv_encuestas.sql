CREATE OR REPLACE PROCEDURE procesar_csv_encuestas()
LANGUAGE plpgsql
AS $$
DECLARE
    v_linea RECORD;
    v_errores INTEGER := 0;
    v_procesadas INTEGER := 0;
    v_dummy INTEGER;
BEGIN
    FOR v_linea IN SELECT * FROM csv_encuestas_temp LOOP
        BEGIN
            -- Validar existencia de IDs referenciados
            BEGIN
                SELECT 1 INTO v_dummy FROM Encuesta WHERE id = v_linea.id_encuesta;
                SELECT 1 INTO v_dummy FROM Pregunta WHERE id = v_linea.id_pregunta;
                SELECT 1 INTO v_dummy FROM OpcionRespuesta WHERE id = v_linea.id_respuesta;
                SELECT 1 INTO v_dummy FROM Encuestado WHERE id = v_linea.id_encuestado;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE EXCEPTION 'ID referenciado no encontrado.';
            END;

            -- Insertar en EncuestaRespondida (si no existe)
            BEGIN
                INSERT INTO EncuestaRespondida (
                    id, encuesta_id, encuestado_id, fecha_hora_respuesta
                )
                VALUES (
                    v_linea.id_respondida,
                    v_linea.id_encuesta,
                    v_linea.id_encuestado,
                    TO_TIMESTAMP(v_linea.fecha_respuesta, 'YYYY-MM-DD HH24:MI:SS')
                );
            EXCEPTION
                WHEN unique_violation THEN
                    -- Ya existe
                    NULL;
            END;

            -- Insertar respuesta seleccionada
            INSERT INTO RespuestaSeleccionada (
                encuesta_respondida_id,
                opcion_respuesta_id
            )
            VALUES (
                v_linea.id_respondida,
                v_linea.id_respuesta
            );

            v_procesadas := v_procesadas + 1;

        EXCEPTION
            WHEN OTHERS THEN
                -- Simulación de rollback parcial
                INSERT INTO csv_errores_log (
                    linea_csv,
                    error_descripcion
                ) VALUES (
                    'EncuestaID: ' || v_linea.id_encuesta || 
                    ', PreguntaID: ' || v_linea.id_pregunta || 
                    ', RespuestaID: ' || v_linea.id_respuesta,
                    SQLERRM
                );
                v_errores := v_errores + 1;
        END;
    END LOOP;

    RAISE NOTICE 'Proceso finalizado.';
    RAISE NOTICE 'Filas procesadas: %', v_procesadas;
    RAISE NOTICE 'Errores detectados: %', v_errores;
END;
$$;
