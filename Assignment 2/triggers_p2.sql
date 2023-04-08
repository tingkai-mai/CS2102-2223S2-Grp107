-- Q1 Delivery Requests
CREATE OR REPLACE FUNCTION trigger_fn_1() RETURNS TRIGGER
AS $$
BEGIN
    IF EXISTS (SELECT * FROM packages P WHERE P.request_id = NEW.id) THEN
        RETURN NEW;
    ELSE
        RETURN NULL;
    END IF; 
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trigger_1
BEFORE INSERT ON delivery_requests
DEFERRABLE INITIALLY IMMEDIATE
FOR EACH ROW EXECUTE FUNCTION trigger_fn_1();

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
        RETURN NULL;
    END IF; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_2
BEFORE INSERT ON packages
FOR EACH ROW EXECUTE FUNCTION trigger_fn_2();

-- Q3 Unsuccessful Pickups 
CREATE OR REPLACE FUNCTION trigger_fn_3() RETURNS TRIGGER
AS $$
DECLARE
    largest_pickup_id INTEGER;
BEGIN
    SELECT COALESCE(MAX(pickup_id),0) INTO largest_pickup_id FROM unsuccessful_pickups U WHERE NEW.request_id = U.request_id;
    IF largest_pickup_id + 1 = NEW.pickup_id THEN 
        RETURN NEW;
    ELSE
        RETURN NULL;
    END IF; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_3
BEFORE INSERT ON unsuccessful_pickups
FOR EACH ROW EXECUTE FUNCTION trigger_fn_3();

-- Q4 Unsuccessful Pickups 
CREATE OR REPLACE FUNCTION trigger_fn_4() RETURNS TRIGGER
AS $$
DECLARE
    req_submission_time TIMESTAMP;
    prev_pickup_time TIMESTAMP;
BEGIN
    -- First unsuccessful pickup
    IF NEW.pickup_id = 1 THEN 
        SELECT DR.submission_time INTO req_submission_time FROM delivery_requests DR WHERE NEW.request_id = DR.id;
        IF NEW.pickup_time > req_submission_time THEN
            RETURN NEW;
        ELSE 
            RETURN NULL;
        END IF;
    -- Check for previous unsuccessful pickup
    ELSE
        SELECT U.pickup_time INTO prev_pickup_time 
        FROM unsuccessful_pickups U 
        WHERE U.request_id = NEW.request_id
        AND U.pickup_id = NEW.pickup_id - 1;
        IF NEW.pickup_time > prev_pickup_time THEN
            RETURN NEW;
        ELSE 
            RETURN NULL;
        END IF;
    END IF; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_4
BEFORE INSERT ON unsuccessful_pickups
FOR EACH ROW EXECUTE FUNCTION trigger_fn_4();

-- Q1 Legs
CREATE OR REPLACE FUNCTION trigger_fn_5() RETURNS TRIGGER
AS $$
DECLARE
    largest_leg_id INTEGER;
BEGIN
    SELECT COALESCE(MAX(leg_id),0) INTO largest_leg_id FROM legs L WHERE NEW.request_id = L.request_id;
    IF largest_leg_id + 1 = NEW.leg_id THEN 
        RETURN NEW;
    ELSE
        RETURN NULL;
    END IF; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_5
BEFORE INSERT ON legs
FOR EACH ROW EXECUTE FUNCTION trigger_fn_5();

-- Q2 & 3 Legs
CREATE OR REPLACE FUNCTION trigger_fn_6() RETURNS TRIGGER
AS $$
DECLARE
    prev_time TIMESTAMP;
    prev_leg_endtime TIMESTAMP;
BEGIN
    SELECT INTO largest_leg_id COALESCE(MAX(leg_id),0) FROM legs L WHERE NEW.request_id = L.request_id;
    -- Check if this is a first leg
    IF NEW.leg_id = 1 THEN
        -- Check if there exists any unsuccessful pickups
        IF EXISTS (SELECT * FROM unsuccessful_pickups U WHERE U.request_id = NEW.request_id) THEN
            SELECT MAX(U.pickup_time) INTO prev_time FROM unsuccessful_pickups U WHERE U.request_id = NEW.request_id;
        ELSE
            SELECT DR.submission_time INTO prev_time FROM delivery_requests DR WHERE NEW.request_id = DR.id;
        END IF;
        -- Check if valid start time
        IF NEW.start_time > prev_time THEN
            RETURN NEW;
        ELSE 
            RETURN NULL;
        END IF;
    ELSE
        -- Query end time of previous leg
        SELECT L.end_time INTO prev_leg_endtime 
        FROM legs L 
        WHERE NEW.request_id = L.request_id
        AND L.leg_id = NEW.leg_id - 1;

        IF prev_leg_endtime IS NULL THEN
            RETURN NULL;
        ELSE IF NEW.start_time > prev_leg_endtime THEN
            RETURN NEW;
        ELSE
            RETURN NULL;
        END IF;
    END IF; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_6
BEFORE INSERT ON legs
FOR EACH ROW EXECUTE FUNCTION trigger_fn_6();