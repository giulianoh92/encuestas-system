CREATE OR REPLACE FUNCTION calcular_firma_csv(contenido TEXT)
RETURNS TEXT LANGUAGE plpgsql IMMUTABLE AS
$$
BEGIN
    RETURN SUBSTRING(md5(contenido) FROM 1 FOR 10);
END;
$$;

CREATE OR REPLACE FUNCTION validar_firma_csv(_fin_line TEXT, contenido TEXT)
RETURNS BOOLEAN LANGUAGE plpgsql AS
$$
DECLARE
    _firma_archivo TEXT;
    _firma_buena   TEXT := calcular_firma_csv(contenido);
BEGIN
    _firma_archivo := SUBSTRING(_fin_line FROM 9 FOR 10);
    RETURN _firma_archivo = _firma_buena;
END;
$$;