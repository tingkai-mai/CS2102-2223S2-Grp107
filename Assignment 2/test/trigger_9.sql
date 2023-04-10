-- Q9 For each delivery request, there can only be at most three unsuccessful deliveries
CREATE OR REPLACE FUNCTION trigger_fn_9() RETURNS TRIGGER
AS $$
DECLARE
    unsuccessful_deliveries_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO unsuccessful_deliveries_count FROM unsuccessful_deliveries u WHERE NEW.request_id = u.request_id;

    IF (unsuccessful_deliveries_count >= 3) THEN
        RAISE EXCEPTION 'Cannot have more than three unsuccessful deliveries in a delivery request!';
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_9
BEFORE INSERT ON unsuccessful_deliveries
FOR EACH ROW EXECUTE FUNCTION trigger_fn_9();

-- Try: Insert more than three unsuccessful deliveries
-- Expected: Should fail
-- Result: psql raises an exception
INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES (19, 4, 9, '2023-04-22 10:00:00', '2023-04-22 12:30:00', 1);
INSERT INTO unsuccessful_deliveries (request_id, leg_id, reason, attempt_time) VALUES (19, 4, 'This one should fail', '2023-04-10 12:45:00');

-- CLEAN UP
DELETE FROM legs WHERE request_id = 19 AND leg_id = 4;