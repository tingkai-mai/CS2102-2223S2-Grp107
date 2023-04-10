-- (1) For each delivery request, the IDs of the legs should be consecutive integers starting from 1.

-- Test 1: DR has no legs associated; Insert legID = 0. Expected: Error
BEGIN TRANSACTION;
SET CONSTRAINTS trigger_1 DEFERRED;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES
(20, 7, 2, 'completed', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00);

INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES (20, '5678901256789012', '2023-03-30 12:55:00', 9);

INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES
(20, 1, 20, 15, 10, 2.5, 'Sports equipment', 100, 20, 15, 10, 2.5);

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES 
(20, 0, 3, '2023-03-30 13:50:00', '2023-03-12 13:55:00', 2);

COMMIT;
\i setup.sql;

-- Test 2: DR has no leg associated; Insert legID = 1. Expected: OK
BEGIN TRANSACTION;
SET CONSTRAINTS trigger_1 DEFERRED;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES
(20, 7, 2, 'completed', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00);

INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES (20, '5678901256789012', '2023-03-30 12:55:00', 9);

INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES
(20, 1, 20, 15, 10, 2.5, 'Sports equipment', 100, 20, 15, 10, 2.5);

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES 
(20, 1, 3, '2023-03-30 13:50:00', '2023-03-12 13:55:00', 2);

COMMIT;
\i setup.sql;

-- Test 3: DR has no leg associated; Insert legID = 2. Expected: Error
BEGIN TRANSACTION;
SET CONSTRAINTS trigger_1 DEFERRED;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES
(20, 7, 2, 'completed', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00);

INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES (20, '5678901256789012', '2023-03-30 12:55:00', 9);

INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES
(20, 1, 20, 15, 10, 2.5, 'Sports equipment', 100, 20, 15, 10, 2.5);

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES 
(20, 2, 3, '2023-03-30 13:50:00', '2023-03-12 13:55:00', 2);

COMMIT;
\i setup.sql;


-- Test 4: DR has no leg associated; Insert legID = 10. Expected: Error
BEGIN TRANSACTION;
SET CONSTRAINTS trigger_1 DEFERRED;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES
(20, 7, 2, 'completed', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00);

INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES (20, '5678901256789012', '2023-03-30 12:55:00', 9);

INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES
(20, 1, 20, 15, 10, 2.5, 'Sports equipment', 100, 20, 15, 10, 2.5);

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES 
(20, 10, 3, '2023-03-30 13:50:00', '2023-03-12 13:55:00', 2);

COMMIT;
\i setup.sql;


-- Test 5: DR has 1 leg associated; Insert legID = 1. Expected: Error
BEGIN TRANSACTION;
SET CONSTRAINTS trigger_1 DEFERRED;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES
(20, 7, 2, 'completed', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00);

INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES (20, '5678901256789012', '2023-03-30 12:55:00', 9);

INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES
(20, 1, 20, 15, 10, 2.5, 'Sports equipment', 100, 20, 15, 10, 2.5);

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES 
(20, 1, 3, '2023-03-30 13:50:00', '2023-03-12 13:55:00', 2);

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES 
(20, 1, 3, '2023-03-30 13:50:00', '2023-03-12 13:55:00', 2);

COMMIT;
\i setup.sql;


-- Test 6: DR has 1 leg associated; Insert legID = 2. Expected: OK
BEGIN TRANSACTION;
SET CONSTRAINTS trigger_1 DEFERRED;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES
(20, 7, 2, 'completed', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00);

INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES (20, '5678901256789012', '2023-03-30 12:55:00', 9);

INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES
(20, 1, 20, 15, 10, 2.5, 'Sports equipment', 100, 20, 15, 10, 2.5);

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES 
(20, 1, 3, '2023-03-30 13:50:00', '2023-03-12 13:55:00', 2);

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES 
(20, 2, 3, '2023-03-30 13:50:00', '2023-03-12 13:55:00', 2);

COMMIT;
\i setup.sql;


-- Test 7: DR has 1 leg associated; Insert legID = 3. Expected: Error
BEGIN TRANSACTION;
SET CONSTRAINTS trigger_1 DEFERRED;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES
(20, 7, 2, 'completed', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00);

INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES (20, '5678901256789012', '2023-03-30 12:55:00', 9);

INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES
(20, 1, 20, 15, 10, 2.5, 'Sports equipment', 100, 20, 15, 10, 2.5);

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES 
(20, 1, 3, '2023-03-30 13:50:00', '2023-03-12 13:55:00', 2);

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES 
(20, 3, 3, '2023-03-30 13:50:00', '2023-03-12 13:55:00', 2);

COMMIT;
\i setup.sql;


-- -- Test 8: DR has 1 leg associated; Insert legID = 10. Expected: Error
BEGIN TRANSACTION;
SET CONSTRAINTS trigger_1 DEFERRED;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES
(20, 7, 2, 'completed', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00);

INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES (20, '5678901256789012', '2023-03-30 12:55:00', 9);

INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES
(20, 1, 20, 15, 10, 2.5, 'Sports equipment', 100, 20, 15, 10, 2.5);

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES 
(20, 1, 3, '2023-03-30 13:50:00', '2023-03-12 13:55:00', 2);

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES 
(20, 10, 3, '2023-03-30 13:50:00', '2023-03-12 13:55:00', 2);

COMMIT;
\i setup.sql;