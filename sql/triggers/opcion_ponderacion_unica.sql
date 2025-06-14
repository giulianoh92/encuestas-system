CREATE OR REPLACE FUNCTION opcion_ponderacion_unica()
RETURNS TRIGGER AS $$
DECLARE
    existe INTEGER;
BEGIN
    IF NEW.ponderacion = 1 THEN
        SELECT COUNT(*) INTO existe
        FROM OpcionRespuesta
        WHERE pregunta_id = NEW.pregunta_id
          AND ponderacion = 1
          AND (TG_OP = 'INSERT' OR id <> NEW.id); -- evita contarse a sí mismo en update

        IF existe > 0 THEN
            RAISE EXCEPTION 'Ya existe una opción con ponderación 1 para esta pregunta.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_opcion_ponderacion_unica
BEFORE INSERT OR UPDATE ON OpcionRespuesta
FOR EACH ROW EXECUTE FUNCTION opcion_ponderacion_unica();
