-- Q13 For each delivery return request, there can be at most three unsuccessful return deliveries
CREATE OR REPLACE FUNCTION trigger_fn_13() RETURNS TRIGGER
AS $$
DECLARE
    unsuccessful_return_deliveries_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO unsuccessful_return_deliveries_count FROM unsuccessful_return_deliveries u WHERE NEW.request_id = u.request_id;

    IF (unsuccessful_return_deliveries_count >= 3) THEN
        RAISE EXCEPTION 'Cannot have more than three unsuccessful return deliveries in a delivery request!';
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_13
BEFORE INSERT ON unsuccessful_deliveries
FOR EACH ROW EXECUTE FUNCTION trigger_fn_13();

-- Try: Insert more than three unsuccessful return deliveries
-- Expected: Should fail
-- Result: psql raises an exception
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, source_facility) VALUES (19, 4, 5, '2023-04-24 10:00:00', '2023-04-24 10:45:00', 2);
INSERT INTO unsuccessful_return_deliveries (request_id, leg_id, reason, attempt_time) VALUES (19, 4, 'This should fail', '2023-04-25 15:00:00');

-- CLEAN UP
DELETE FROM return_legs WHERE request_id = 19 AND leg_id = 4;