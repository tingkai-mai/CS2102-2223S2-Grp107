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
        -- RAISE EXCEPTION 'Unsuccessful pickup ID is invalid. Unsuccessful pickup IDs must be consecutive integers starting from 1';
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
    SELECT DR.submission_time INTO req_submission_time FROM delivery_requests DR WHERE NEW.request_id = DR.id;
    -- First unsuccessful pickup
    IF NEW.pickup_id = 1 THEN
        IF NEW.pickup_time > req_submission_time THEN
            RETURN NEW;
        ELSE
            -- RAISE EXCEPTION 'Timestamp of unsuccessful pickup is invalid.';
            RETURN NULL;
        END IF;
    -- Check for previous unsuccessful pickup
    ELSE
        SELECT U.pickup_time INTO prev_pickup_time 
        FROM unsuccessful_pickups U 
        WHERE U.request_id = NEW.request_id
        AND U.pickup_id = NEW.pickup_id - 1;
        IF NEW.pickup_time > prev_pickup_time AND NEW.pickup_time > req_submission_time THEN
            RETURN NEW;
        ELSE
            -- RAISE EXCEPTION 'Timestamp of unsuccessful pickup is invalid.';
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
        -- RAISE EXCEPTION 'Leg ID is invalid. Leg IDs must be consecutive integers starting from 1';
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
            -- RAISE EXCEPTION 'Start time of first leg is invalid.';
            RETURN NULL;
        END IF;
    ELSE
        -- Query end time of previous leg
        SELECT L.end_time INTO prev_leg_endtime 
        FROM legs L 
        WHERE NEW.request_id = L.request_id
        AND L.leg_id = NEW.leg_id - 1;

        IF prev_leg_endtime IS NULL THEN
            -- RAISE EXCEPTION 'End time of previous leg cannot be NULL.';
            RETURN NULL;
        ELSIF NEW.start_time > prev_leg_endtime THEN
            RETURN NEW;
        ELSE
            -- RAISE EXCEPTION 'Start time of leg is invalid.';
            RETURN NULL;
        END IF;
    END IF; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_6
BEFORE INSERT ON legs
FOR EACH ROW EXECUTE FUNCTION trigger_fn_6();

-- Q8 Unsuccessful deliveries
CREATE OR REPLACE FUNCTION trigger_fn_8() RETURNS TRIGGER
AS $$ 
DECLARE 
    leg_start_time TIMESTAMP;
BEGIN
    SELECT start_time INTO leg_start_time FROM Legs L WHERE L.leg_id = NEW.leg_id AND NEW.request_id = L.request_id;
    
    IF NEW.attempt_time > leg_start_time THEN
        -- RAISE EXCEPTION 'The timestamp of each unsuccessful_delivery must be after the start_time of the corresponding leg.';
        RETURN NULL;
    ELSE 
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_8
BEFORE INSERT ON unsuccessful_deliveries
FOR EACH ROW EXECUTE FUNCTION trigger_fn_8();

-- Q9 For each delivery request, there can only be at most three unsuccessful deliveries
CREATE OR REPLACE FUNCTION trigger_fn_9() RETURNS TRIGGER
AS $$
DECLARE
    unsuccessful_deliveries_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO unsuccessful_deliveries_count FROM unsuccessful_deliveries u WHERE NEW.request_id = u.request_id;

    IF (unsuccessful_deliveries_count >= 3) THEN
        -- RAISE EXCEPTION 'Cannot have more than three unsuccessful deliveries in a delivery request!';
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_9
BEFORE INSERT ON unsuccessful_deliveries
FOR EACH ROW EXECUTE FUNCTION trigger_fn_9();


-- Q10 Cancelled requests
CREATE OR REPLACE FUNCTION trigger_fn_10() RETURNS TRIGGER
AS $$
DECLARE 
    delivery_req_submission_time TIMESTAMP;
BEGIN
    SELECT D.submission_time INTO delivery_req_submission_time FROM delivery_requests D WHERE D.id = NEW.id; 
    IF NEW.cancel_time <= delivery_req_submission_time THEN 
        -- RAISE EXCEPTION 'The cancel_time of a cancelled request must be after the submission_time of the corresponding delivery request.';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_10
BEFORE INSERT ON cancelled_requests
FOR EACH ROW EXECUTE FUNCTION trigger_fn_10();

-- Q11 For each delivery request, first return_leg's ID should be 1, second return_leg's ID should be 2, and so on
CREATE OR REPLACE FUNCTION trigger_fn_11() RETURNS TRIGGER
AS $$
DECLARE
    largest_leg_id INTEGER;
BEGIN
    SELECT COALESCE(MAX(r.leg_id), 0) INTO largest_leg_id FROM return_legs r WHERE request_id = NEW.request_id;
    IF NEW.leg_id = largest_leg_id + 1 THEN
        RETURN NEW;
    ELSE
        -- RAISE EXCEPTION 'Leg ID is invalid. Leg IDs must be consecutive integers starting from 1.'
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_11
BEFORE INSERT ON return_legs
FOR EACH ROW EXECUTE FUNCTION trigger_fn_11();

-- Q12 For a delivery request, the first return leg cannot be inserted if... total of 3 conditions
CREATE OR REPLACE FUNCTION trigger_fn_12() RETURNS TRIGGER
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM legs L WHERE L.request_id = NEW.request_id) THEN 
        -- RAISE EXCEPTION 'There should be an existing leg for the delivery request.';
        RETURN NULL;
    ELSIF NEW.start_time < (SELECT MAX(end_time) FROM legs L WHERE L.request_id = NEW.request) THEN 
        -- RAISE EXCEPTION 'The end_time of the last existing leg should be after the start_time of the return leg.';
        RETURN NULL;
    ELSIF EXISTS (SELECT 1 FROM cancelled_requests C WHERE C.id = NEW.request_id) THEN
        -- Nested condition...
        IF NEW.start_time < (SELECT cancel_time FROM cancelled_requests C WHERE C.id = NEW.request_id) THEN 
            -- RAISE EXCEPTION 'The start_time of the return_leg should be after the cancel_time of the request.';
            RETURN NULL;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_12
BEFORE INSERT ON return_legs 
FOR EACH ROW EXECUTE FUNCTION trigger_fn_12();

-- Q13 For each delivery return request, there can be at most three unsuccessful return deliveries
CREATE OR REPLACE FUNCTION trigger_fn_13() RETURNS TRIGGER
AS $$
DECLARE
    unsuccessful_return_deliveries_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO unsuccessful_return_deliveries_count FROM unsuccessful_return_deliveries u WHERE NEW.request_id = u.request_id;

    IF (unsuccessful_return_deliveries_count >= 3) THEN
        -- RAISE EXCEPTION 'Cannot have more than three unsuccessful return deliveries in a delivery request!';
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_13
BEFORE INSERT ON unsuccessful_deliveries
FOR EACH ROW EXECUTE FUNCTION trigger_fn_13();


-- Q14 Unsuccessful return deliveries 
CREATE OR REPLACE FUNCTION trigger_fn_14() RETURNS TRIGGER 
AS $$
DECLARE 
	leg_timestamp TIMESTAMP;
BEGIN
	SELECT start_time INTO leg_timestamp
	FROM return_legs L
	WHERE L.id = NEW.id;

	IF NEW.attempt_time <= delivery_timestamp THEN
		-- RAISE EXCEPTION 'Delivery timestamp should have a value greater than leg timestamp.';
		RETURN NULL;
	END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_14 
BEFORE INSERT ON unsuccessful_return_deliveries
FOR EACH ROW EXECUTE FUNCTION trigger_fn_14();