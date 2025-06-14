CREATE OR REPLACE FUNCTION upper_razon_social()
RETURNS TRIGGER AS $$
BEGIN
    NEW.razon_social := UPPER(NEW.razon_social);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_upper_razon_social
BEFORE INSERT OR UPDATE ON Empresa
FOR EACH ROW EXECUTE FUNCTION upper_razon_social();
