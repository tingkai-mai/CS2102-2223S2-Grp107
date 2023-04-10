-- Unsuccessful_pickups related:
-- (3) For each delivery request, the IDs of the unsuccessful pickups should be consecutive integers starting from 1.
-- Test 1: DR has no UP associated; Insert UP = 0. Expected: Error
BEGIN TRANSACTION;
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(19, 0, 1, '2023-03-30 13:00:00', 'Incorrect address provided');

COMMIT;
\i setup.sql;

-- Test 2: DR has no UP associated; Insert UP = 1. Expected: OK
BEGIN TRANSACTION;
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(19, 1, 1, '2023-03-30 13:00:00', 'Incorrect address provided');

COMMIT;
\i setup.sql;

-- Test 3: DR has no UP associated; Insert UP = 2. Expected: Error
BEGIN TRANSACTION;

INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(19, 2, 1, '2023-03-30 13:00:00', 'Incorrect address provided');

COMMIT;
\i setup.sql;

-- Test 4: DR has no UP associated; Insert UP = 10. Expected: Error
BEGIN TRANSACTION;

INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(19, 10, 1, '2023-03-30 13:00:00', 'Incorrect address provided');

COMMIT;
\i setup.sql;

-- Test 5: DR has 1 UP associated; Insert UP = 1. Expected: Error
BEGIN TRANSACTION;

INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(19, 1, 1, '2023-03-30 13:00:00', 'Incorrect address provided');

INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(19, 1, 2, '2023-03-30 20:10:00', 'Incorrect address provided');

COMMIT;
\i setup.sql;

-- Test 6: DR has 1 UP associated; Insert UP = 2. Expected: OK
BEGIN TRANSACTION;
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(19, 1, 1, '2023-03-30 13:00:00', 'Incorrect address provided');

INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(19, 2, 1, '2023-03-30 13:10:00', 'Incorrect address provided');

COMMIT;
\i setup.sql;

-- Test 7: DR has 1 UP associated; Insert UP = 3. Expected: Error
BEGIN TRANSACTION;

INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(19, 1, 1, '2023-03-30 13:00:00', 'Incorrect address provided');

INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(19, 3, 1, '2023-03-30 13:10:00', 'Incorrect address provided');

COMMIT;
\i setup.sql;

-- -- Test 8: DR has 1 UP associated; Insert UP = 10. Expected: Error
-- Test 7: DR has 1 UP associated; Insert UP = 3. Expected: Error
BEGIN TRANSACTION;

INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(19, 1, 1, '2023-03-30 13:00:00', 'Incorrect address provided');

INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(19, 10, 3, '2023-03-30 13:10:00', 'Incorrect address provided');

COMMIT;
\i setup.sql;
-- \i setup.sql;