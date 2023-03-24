-- TRIGGER 1
CREATE CONSTRAINT TRIGGER constraint_delivery_request_has_package
AFTER INSERT OR UPDATE ON delivery_requests
DEFERABLE INITIALLY IMMEDIATE
FOR EACH ROW
EXECUTE FUNCTION constraint_delivery_request_has_package_func();

CREATE OR REPLACE FUNCTION constraint_delivery_request_has_package_func() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM packages p WHERE p.request_id = NEW.id) THEN RETURN NEW;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;