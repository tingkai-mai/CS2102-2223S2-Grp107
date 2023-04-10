-- Delivery_requests related:
-- (1) Each delivery request has at least one package.

-- Test 1: Insert DR with one package associated. Expected: OK
BEGIN TRANSACTION;
SET CONSTRAINTS trigger_1 DEFERRED;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES
(20, 7, 2, 'unsuccessful', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00);

INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES
(20, 1, 20, 15, 10, 2.5, 'Sports equipment', 100, 20, 15, 10, 2.5);
COMMIT;

\i setup.sql;
-- Test 2: Insert DR with two package associated. Expected: OK
BEGIN TRANSACTION;
SET CONSTRAINTS trigger_1 DEFERRED;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES
(20, 7, 2, 'unsuccessful', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00);

INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES
(20, 1, 20, 15, 10, 2.5, 'Sports equipment', 100, 20, 15, 10, 2.5);

INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES
(20, 2, 20, 15, 10, 2.5, 'Sports equipment', 100, 20, 15, 10, 2.5);

SELECT * FROM delivery_requests;
COMMIT;
\i setup.sql;

-- Test 3: Insert DR with no package associated. Expected: Error
BEGIN TRANSACTION;
SET CONSTRAINTS trigger_1 DEFERRED;
INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES
(20, 7, 2, 'unsuccessful', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00);
COMMIT;

\i setup.sql;