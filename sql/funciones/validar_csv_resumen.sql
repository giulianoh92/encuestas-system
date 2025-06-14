CREATE OR REPLACE FUNCTION validar_csv_resumen()
RETURNS TEXT AS $$
DECLARE
    total_registros INTEGER := 0;
    registros_unicos INTEGER := 0;
BEGIN
    SELECT COUNT(*) INTO total_registros FROM csv_encuestas_temp;

    SELECT COUNT(DISTINCT id_respondida || '-' || id_encuestado)
    INTO registros_unicos
    FROM csv_encuestas_temp;

    IF total_registros = registros_unicos THEN
        RETURN 'VALIDO';
    ELSE
        RETURN 'DUPLICADOS';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;
