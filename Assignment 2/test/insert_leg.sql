-- insert_leg(
--     request_id INTEGER,
--     handler_id INTEGER,
--     start_time TIMESTAMP,
--     destination_facility INTEGER
-- )

-- End time shud be null

CALL insert_leg(18, 1, '2023-04-30 13:30:00', 3);
-- CALL insert_leg(18, 1, '2023-05-30 13:30:00', 3);

BEGIN TRANSACTION;
SET CONSTRAINTS trigger_1 DEFERRED;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES
(20, 4, 2, 'accepted', '88 Elm St', '10003', 'Jane Smith', '77 Pine St', '10008', '2023-03-15 10:30:00', '2023-03-16', 1, 10.00);
INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES
(20, '1234567812345678', '2023-03-10 14:25:00', 5);
INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES
(20, 1, 20, 15, 10, 2.5, 'Books', 50, 20, 15, 10, 2.5);
COMMIT;

CALL insert_leg(20, 1, '2023-05-30 13:30:00', 3);