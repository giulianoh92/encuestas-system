CREATE OR REPLACE PROCEDURE cargar_csv_respuestas(p_path TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
    /* Buffers y contadores */
    v_lines   TEXT[];
    v_raw     TEXT;
    v_fin     TEXT;
    v_total   INT;          -- declarado en footer
    v_leidas  INT;          -- realmente presentes
    v_ok      INT := 0;     -- aceptadas
    v_bad     INT := 0;     -- rechazadas
    v_contenido_datos TEXT := '';

    /* Campos parseados */
    v_encuesta_id        INT;
    v_pregunta_id        INT;
    v_opcion_id          INT;
    v_fecha_respuesta    DATE;
    v_encuestador_id     INT;
    v_ext_enc_resp_id    BIGINT;
    v_encuestado_id      INT;
BEGIN
    /* 1) Cargar archivo completo y quitar CR */
    v_lines := string_to_array(
                 translate(pg_read_file(p_path), E'\r', ''),
                 E'\n');

    IF v_lines IS NULL OR array_length(v_lines,1) < 3 THEN
        RAISE EXCEPTION 'El archivo % está vacío o incompleto.', p_path;
    END IF;

    /* 2) Analizar footer */
    v_fin   := v_lines[array_length(v_lines,1)];
    v_total := COALESCE(SUBSTRING(v_fin FROM 4 FOR 5)::INT, 0);
    v_leidas := array_length(v_lines,1) - 2;         -- sin header/footer

    IF v_total <> v_leidas THEN
        RAISE EXCEPTION
            'Inconsistencia: el archivo declara % registros pero contiene % líneas de datos.',
            v_total, v_leidas;
    END IF;

    /* 3) Procesar cada línea de datos (longitud fija = 57) */
    FOR i IN 2 .. array_length(v_lines,1)-1 LOOP
        v_raw := trim(v_lines[i]);
        v_contenido_datos := v_contenido_datos || v_raw;   -- para la firma

        IF v_raw = '' THEN CONTINUE; END IF;

        BEGIN
            IF length(v_raw) <> 57 THEN
                RAISE EXCEPTION 'Longitud inesperada (%).', length(v_raw);
            END IF;

            v_encuesta_id        := SUBSTRING(v_raw,  1,  6)::INT;
            v_pregunta_id        := SUBSTRING(v_raw,  7,  8)::INT;
            v_opcion_id          := SUBSTRING(v_raw, 15, 12)::INT;
            v_fecha_respuesta    := to_date(SUBSTRING(v_raw,27, 8), 'YYYYMMDD');
            v_encuestador_id     := SUBSTRING(v_raw,35, 4)::INT;
            v_ext_enc_resp_id    := SUBSTRING(v_raw,39,12)::BIGINT;
            v_encuestado_id      := SUBSTRING(v_raw,51, 7)::INT;

            /* -------- Validaciones de integridad -------- */
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

            /* ----- Inserción en staging ----- */
            INSERT INTO csv_respuestas(
                encuesta_id, pregunta_id, opcion_respuesta_id,
                fecha_respuesta, encuestador_id, encuestado_id,
                ext_encuesta_resp_id, linea_original)
            VALUES (
                v_encuesta_id, v_pregunta_id, v_opcion_id,
                v_fecha_respuesta, v_encuestador_id, v_encuestado_id,
                v_ext_enc_resp_id, v_raw);

            v_ok := v_ok + 1;

        EXCEPTION WHEN OTHERS THEN
            INSERT INTO csv_errores_log(linea_csv, error_descripcion)
            VALUES (v_raw, SQLERRM);
            v_bad := v_bad + 1;
        END;
    END LOOP;

    /* 4) Verificar firma */
    IF NOT validar_firma_csv(v_fin, v_contenido_datos) THEN
        RAISE EXCEPTION 'Firma del archivo inválida. No se insertó ningún registro.';
    END IF;

    RAISE NOTICE 'CSV leído. Aceptados: %, Rechazados: %', v_ok, v_bad;
END;
$$;
