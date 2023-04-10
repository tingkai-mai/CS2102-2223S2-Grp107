-- Q12 For a delivery request, the first return leg cannot be inserted if... total of 3 conditions
CREATE OR REPLACE FUNCTION trigger_fn_12() RETURNS TRIGGER
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM legs L WHERE L.request_id = NEW.request_id) THEN 
        RAISE EXCEPTION 'There should be an existing leg for the delivery request.';
        RETURN NULL;
    ELSIF NEW.start_time < (SELECT MAX(end_time) FROM legs L WHERE L.request_id = NEW.request_id) THEN 
        RAISE EXCEPTION 'The end_time of the last existing leg should be after the start_time of the return leg.';
        RETURN NULL;
    ELSIF EXISTS (SELECT 1 FROM cancelled_requests C WHERE C.id = NEW.request_id) THEN
        -- Nested condition...
        IF NEW.start_time < (SELECT cancel_time FROM cancelled_requests C WHERE C.id = NEW.request_id) THEN 
            RAISE EXCEPTION 'The start_time of the return_leg should be after the cancel_time of the request.';
            RETURN NULL;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_12
BEFORE INSERT ON return_legs 
FOR EACH ROW EXECUTE FUNCTION trigger_fn_12();

-- Try: Insert a first return leg with no existing leg for the delivery request
-- Expected: Should fail 
-- Result: psql raises exception "there should be an existing leg for the delivery request"
BEGIN TRANSACTION;
SET CONSTRAINTS trigger_1 DEFERRED;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES (20, 4, 2, 'cancelled', '88 Elm St', '10003', 'Jane Smith', '77 Pine St', '10008', '2023-03-15 10:30:00', '2023-03-16', 1, 10.00);
INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES (20, 1, 20, 15, 10, 2.5, 'yoga mat', 100, 20, 15, 10, 2.5);
COMMIT;

INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, source_facility) VALUES (20, 1, 5, '2023-03-15 13:15:00', '2023-03-15 14:00:00', 1);

-- Try: Insert a first return leg with start time BEFORE the end time of the last existing leg
-- Expected: Should fail    
-- Result: psql raises exception "the end time of the last existing leg should be after the start_time of the return leg"
INSERT INTO cancelled_or_unsuccessful_requests (id) VALUES (18);
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, source_facility) VALUES (18, 1, 5, '2023-03-26 14:00:00', '2023-03-26 16:00:00', 1);

-- Try: Insert a first return leg with start time EQUAL TO the end time of the last existing leg
-- Expected: Should pass
-- Result: Passes
INSERT INTO cancelled_or_unsuccessful_requests (id) VALUES (18);
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, source_facility) VALUES (18, 1, 5, '2023-03-26 15:00:00', '2023-03-26 16:00:00', 1);

-- Try: Insert a first return leg whose start time is BEFORE the cancel_time of the request (assuming a cancelled request exists) 
-- Expected: Should fail 
-- Result: psql raises exception "the start_time of the return_leg should be after the cancel_time of the request"
INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES (20, '12383578622345678', '2023-03-15 10:30:00', 5);
INSERT INTO cancelled_or_unsuccessful_requests (id) VALUES (20);
INSERT INTO cancelled_requests (id, cancel_time) VALUES (20, '2023-03-29 10:30:00');
INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES (20, 1, 5, '2023-03-16 13:15:00', '2023-03-16 14:00:00', 1);
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, source_facility) VALUES (20, 1, 5, '2023-03-18 14:00:00', '2023-03-18 16:00:00', 1);

-- Try: Insert a first return leg whose start time is EQUAL TO the cancel_time of the request (assuming a cancelled request exists) 
-- Expected: Should pass
-- Result: Passes
INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES (20, '12383578622345678', '2023-03-15 10:30:00', 5);
INSERT INTO cancelled_or_unsuccessful_requests (id) VALUES (20);
INSERT INTO cancelled_requests (id, cancel_time) VALUES (20, '2023-03-29 10:30:00');
INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES (20, 1, 5, '2023-03-16 13:15:00', '2023-03-16 14:00:00', 1);
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, source_facility) VALUES (20, 1, 5, '2023-03-29 10:30:00', '2023-03-18 16:00:00', 1);

-- CLEAN UP
DELETE FROM legs WHERE request_id = 20 AND leg_id = 1;
DELETE FROM accepted_requests WHERE id = 20;
DELETE FROM delivery_requests WHERE id = 20;
DELETE FROM packages WHERE request_id = 20;