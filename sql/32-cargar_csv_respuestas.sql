CREATE OR REPLACE PROCEDURE cargar_csv_respuestas (p_path  TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public          -- ajusta si usas otro esquema
AS $$
DECLARE
    /* --- Buffers y contadores ----------------------------------------- */
    v_lines   TEXT[];      -- archivo en memoria, ya sin CR
    v_raw     TEXT;        -- línea actual
    v_fin     TEXT;        -- footer  "FIN00040..."
    v_total   INT;         -- cantidad declarada en el footer
    v_ok      INT := 0;    -- aceptadas
    v_bad     INT := 0;    -- rechazadas
    v_contenido_valido TEXT := '';  -- concat de líneas válidas (firma)
    v_contenido_datos TEXT := '';


    /* --- Campos parseados --------------------------------------------- */
    v_encuesta_id      INT;
    v_pregunta_id      INT;
    v_opcion_id        INT;
    v_fecha_respuesta  DATE;
    v_encuestador_id   INT;
    v_encuestado_id  INT;
BEGIN
    /*--------------------------------------------------------------------
     * 1) Leer el archivo completo, limpiando CR (formato Windows).
     *-------------------------------------------------------------------*/
    v_lines := string_to_array(
                 translate(pg_read_file(p_path), E'\r', ''),
                 E'\n');

    IF v_lines IS NULL OR array_length(v_lines, 1) < 3 THEN
        RAISE EXCEPTION 'El archivo % está vacío o incompleto.', p_path;
    END IF;

    /*--------------------------------------------------------------------
     * 2) Header / Footer  y total declarado
     *-------------------------------------------------------------------*/
    v_fin   := v_lines[array_length(v_lines, 1)];
    v_total := COALESCE(SUBSTRING(v_fin FROM 4 FOR 5)::INT, 0);

    /*--------------------------------------------------------------------
     * 3) Procesar cada línea de datos (2 .. penúltima)
     *-------------------------------------------------------------------*/
    FOR i IN 2 .. array_length(v_lines, 1) - 1 LOOP
        v_raw := trim(v_lines[i]);


        v_contenido_datos := v_contenido_datos || v_raw || E'\n';

        IF v_raw = '' THEN
            CONTINUE;                   -- salta líneas en blanco
        END IF;

        BEGIN  -- bloque por línea
            /* 3.1  Parseo fijo — 50 caracteres exactos */
            IF length(v_raw) <> 50 THEN
                RAISE EXCEPTION 'Longitud inesperada (%).', length(v_raw);
            END IF;

            v_encuesta_id     := SUBSTRING(v_raw FROM  1 FOR  6)::INT;
            v_pregunta_id     := SUBSTRING(v_raw FROM  7 FOR  8)::INT;
            v_opcion_id       := SUBSTRING(v_raw FROM 15 FOR 12)::INT;
            v_fecha_respuesta := to_date(SUBSTRING(v_raw FROM 27 FOR  8), 'YYYYMMDD');
            v_encuestador_id  := SUBSTRING(v_raw FROM 35 FOR  4)::INT;
            v_encuestado_id := SUBSTRING(v_raw FROM 39 FOR 12)::INT;

            /* 3.2  Validaciones de integridad */
            IF NOT EXISTS (SELECT 1 FROM Encuesta WHERE id = v_encuesta_id) THEN
                RAISE EXCEPTION 'Encuesta % inexistente', v_encuesta_id;
            END IF;

            IF NOT EXISTS (
                   SELECT 1 FROM Pregunta
                   WHERE id = v_pregunta_id AND encuesta_id = v_encuesta_id) THEN
                RAISE EXCEPTION 'Pregunta % inválida o no pertenece a la encuesta %',
                                v_pregunta_id, v_encuesta_id;
            END IF;

            IF NOT EXISTS (
                   SELECT 1 FROM OpcionRespuesta
                   WHERE id = v_opcion_id AND pregunta_id = v_pregunta_id) THEN
                RAISE EXCEPTION 'Opción % inválida para la pregunta %',
                                v_opcion_id, v_pregunta_id;
            END IF;

            IF NOT EXISTS (SELECT 1 FROM Solicitante WHERE id = v_encuestador_id) THEN
                RAISE EXCEPTION 'Encuestador % inexistente', v_encuestador_id;
            END IF;

            IF NOT EXISTS (SELECT 1 FROM Encuestado WHERE id = v_encuestado_id) THEN
                RAISE EXCEPTION 'Encuestado % inexistente', v_encuestado_id;
            END IF;

            IF EXISTS (
                   SELECT 1 FROM EncuestaRespondida
                   WHERE encuesta_id = v_encuesta_id
                     AND encuestado_id = v_encuestado_id) THEN
                RAISE EXCEPTION 'Duplicada: el usuario % ya respondió la encuesta %',
                                v_encuestado_id, v_encuesta_id;
            END IF;

            /* 3.3  Insertar registro válido */
            INSERT INTO csv_respuestas
                  (encuesta_id, pregunta_id, opcion_respuesta_id,
                   fecha_respuesta, encuestador_id, encuestado_id,
                   linea_original)
            VALUES (v_encuesta_id, v_pregunta_id, v_opcion_id,
                    v_fecha_respuesta, v_encuestador_id, v_encuestado_id,
                    v_raw);

            v_contenido_valido := v_contenido_valido || v_raw || E'\n';
            v_ok := v_ok + 1;

        EXCEPTION WHEN OTHERS THEN          -- cualquier fallo se loguea
            INSERT INTO csv_errores_log (linea_csv, error_descripcion)
            VALUES (v_raw, SQLERRM);
            v_bad := v_bad + 1;
            -- continúa con la siguiente línea
        END;
    END LOOP;

    /*--------------------------------------------------------------------
     * 4) Post-validaciones globales (sin abortar la transacción)
     *-------------------------------------------------------------------*/
    IF v_ok <> v_total THEN
        RAISE WARNING
          'Inconsistencia: el archivo declara % registros pero se validaron % (rechazados %).',
          v_total, v_ok, v_bad;
    END IF;

    IF NOT validar_firma_csv(v_fin, v_contenido_datos) THEN
        RAISE WARNING 'Firma del archivo inválida.';
    END IF;

    /*--------------------------------------------------------------------
     * 5) Reporte final
     *-------------------------------------------------------------------*/
    RAISE NOTICE 'Carga de CSV terminada. Aceptados: %, Rechazados: %',
                 v_ok, v_bad;
END;
$$;
