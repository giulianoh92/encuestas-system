/**************************************************************************************
 * PROCEDIMIENTO ADAPTADO A csv_respuestas
 * (inserta RespuestaSeleccionada con el id de EncuestaRespondida correspondiente)
 *************************************************************************************/
CREATE OR REPLACE PROCEDURE procesar_csv_respuestas()
LANGUAGE plpgsql
AS $$
DECLARE
    v_linea              RECORD;
    v_errores            INTEGER := 0;
    v_procesadas         INTEGER := 0;
    v_enc_resp_id        INTEGER;     -- << nuevo >>
BEGIN
    FOR v_linea IN
        SELECT *
        FROM   csv_respuestas         -- sólo las líneas ya validadas
    LOOP
        BEGIN
            /****************** VALIDACIONES DE INTEGRIDAD ************************/

            -- 1) Encuesta abierta
            PERFORM 1
            FROM   Encuesta
            WHERE  id = v_linea.encuesta_id
              AND  estado_id = 2;
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Encuesta % no encontrada o no está abierta',
                                v_linea.encuesta_id;
            END IF;

            -- 2) Pregunta pertenece a esa encuesta
            PERFORM 1
            FROM   Pregunta
            WHERE  id = v_linea.pregunta_id
              AND  encuesta_id = v_linea.encuesta_id;
            IF NOT FOUND THEN
                RAISE EXCEPTION 'La pregunta % no pertenece a la encuesta %',
                                v_linea.pregunta_id, v_linea.encuesta_id;
            END IF;

            -- 3) Opción válida para la pregunta
            PERFORM 1
            FROM   OpcionRespuesta
            WHERE  id = v_linea.opcion_respuesta_id
              AND  pregunta_id = v_linea.pregunta_id;
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Opción % no corresponde a la pregunta %',
                                v_linea.opcion_respuesta_id, v_linea.pregunta_id;
            END IF;

            -- 4) Encuestado existente
            PERFORM 1
            FROM   Encuestado
            WHERE  id = v_linea.encuestado_id;
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Encuestado % no encontrado',
                                v_linea.encuestado_id;
            END IF;

            -- 5) Encuestador = Solicitante y coincide con la encuesta
            PERFORM 1
            FROM   Solicitante s
            WHERE  s.id = v_linea.encuestador_id::INT;
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Solicitante (encuestador) % inexistente',
                                v_linea.encuestador_id;
            END IF;

            PERFORM 1
            FROM   Encuesta e
            WHERE  e.id = v_linea.encuesta_id
              AND  e.solicitante_id = v_linea.encuestador_id::INT;
            IF NOT FOUND THEN
                RAISE EXCEPTION 'El solicitante % no está asociado a la encuesta %',
                                v_linea.encuestador_id, v_linea.encuesta_id;
            END IF;

            /****************** INSERCIÓN EN TABLAS DEFINITIVAS *******************/

            /* 1) Obtener/insertar EncuestaRespondida y capturar su id
                   (la combinación encuesta_id + encuestado_id es única)    */
            INSERT INTO EncuestaRespondida (
                id,
                encuesta_id,
                encuestado_id,
                fecha_hora_respuesta
            )
            VALUES (
                v_linea.ext_encuesta_resp_id,  -- id externo
                v_linea.encuesta_id,
                v_linea.encuestado_id,
                v_linea.fecha_respuesta
            )
            ON CONFLICT (encuesta_id, encuestado_id) DO NOTHING
            RETURNING id INTO v_enc_resp_id;

            -- Si hubo conflicto, recuperamos el id existente
            IF v_enc_resp_id IS NULL THEN
                SELECT id
                INTO   v_enc_resp_id
                FROM   EncuestaRespondida
                WHERE  encuesta_id  = v_linea.encuesta_id
                  AND  encuestado_id = v_linea.encuestado_id;
            END IF;

            /* 2) Insertar la RespuestaSeleccionada usando ese id            */
            INSERT INTO RespuestaSeleccionada (
                encuesta_respondida_id,
                opcion_respuesta_id,
                pregunta_id
            )
            VALUES (
                v_enc_resp_id,
                v_linea.opcion_respuesta_id,
                v_linea.pregunta_id
            );

            v_procesadas := v_procesadas + 1;

        EXCEPTION WHEN OTHERS THEN
            INSERT INTO csv_errores_log (linea_csv, error_descripcion)
            VALUES (v_linea.linea_original, SQLERRM);
            v_errores := v_errores + 1;
        END;
    END LOOP;

    /************************** RESUMEN FINAL **********************************/
    RAISE NOTICE 'Proceso finalizado.';
    RAISE NOTICE 'Filas correctamente procesadas: %', v_procesadas;
    RAISE NOTICE 'Filas con error registradas en csv_errores_log: %', v_errores;
END;
$$;
