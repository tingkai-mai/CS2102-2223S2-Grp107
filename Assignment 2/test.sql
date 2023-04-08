-- Q1 Delivery Requests
CREATE OR REPLACE FUNCTION trigger_fn_1() RETURNS TRIGGER
AS $$
BEGIN
    IF EXISTS (SELECT * FROM packages P WHERE P.request_id = NEW.id) THEN
        RETURN NEW;
    ELSE
        -- RAISE EXCEPTION 'Each delivery request must have at least one package.';
        RETURN NULL;
    END IF; 
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trigger_1
AFTER INSERT ON delivery_requests
DEFERRABLE INITIALLY IMMEDIATE
FOR EACH ROW 
EXECUTE FUNCTION trigger_fn_1();

-- Q2 Package
CREATE OR REPLACE FUNCTION trigger_fn_2() RETURNS TRIGGER
AS $$
DECLARE
    largest_pkg_id INTEGER;
BEGIN
    SELECT COALESCE(MAX(package_id),0) INTO largest_pkg_id FROM packages P WHERE NEW.request_id = P.request_id;
    IF largest_pkg_id + 1 = NEW.package_id THEN 
        RETURN NEW;
    ELSE
        -- RAISE EXCEPTION 'Package ID is invalid. Package IDs must be consecutive integers starting from 1';
        RETURN NULL;
    END IF; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_2
BEFORE INSERT ON packages
FOR EACH ROW EXECUTE FUNCTION trigger_fn_2();