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
              -- Validaciones de existencia
              PERFORM 1 FROM Encuesta WHERE id = v_linea.id_encuesta AND estado_id = 2;
              IF NOT FOUND THEN
                 RAISE EXCEPTION 'Encuesta no encontrada o no está abierta';
              END IF;

            PERFORM 1 FROM Pregunta WHERE id = v_linea.id_pregunta AND encuesta_id = v_linea.id_encuesta;
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Pregunta no encontrada o no pertenece a la encuesta';
            END IF;

            PERFORM 1 FROM OpcionRespuesta 
            WHERE id = v_linea.id_respuesta AND pregunta_id = v_linea.id_pregunta;
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Opción no encontrada o no corresponde a la pregunta';
            END IF;

            PERFORM 1 FROM Encuestado WHERE id = v_linea.id_encuestado;
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Encuestado no encontrado';
            END IF;

            -- Insertar en EncuestaRespondida si no existe
            BEGIN
                INSERT INTO EncuestaRespondida (
                    id, encuesta_id, encuestado_id, fecha_hora_respuesta
                )
                VALUES (
                    v_linea.id_respondida,
                    v_linea.id_encuesta,
                    v_linea.id_encuestado,
                    v_linea.fecha_respuesta
                );
            EXCEPTION WHEN unique_violation THEN
                -- Ya existe, continuar
                NULL;
            END;

            -- Insertar en RespuestaSeleccionada
            INSERT INTO RespuestaSeleccionada (
                encuesta_respondida_id,
                opcion_respuesta_id,
                pregunta_id
            )
            VALUES (
                v_linea.id_respondida,
                v_linea.id_respuesta,
                v_linea.id_pregunta
            );

            v_procesadas := v_procesadas + 1;

        EXCEPTION
            WHEN OTHERS THEN
                INSERT INTO csv_errores_log (
                    linea_csv,
                    error_descripcion
                ) VALUES (
                    'EncuestaID: ' || v_linea.id_encuesta ||
                    ', PreguntaID: ' || v_linea.id_pregunta ||
                    ', RespuestaID: ' || v_linea.id_respuesta ||
                    ', EncuestadoID: ' || v_linea.id_encuestado,
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
