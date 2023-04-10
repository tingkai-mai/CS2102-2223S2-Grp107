-- (7) For each delivery request, the first return_leg’s ID should 1, the second return_leg’s ID should be 2,
-- and so on.
-- Test 1: DR has 1 leg associated; Insert legID = 3. Expected: Error
BEGIN TRANSACTION;
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, source_facility) VALUES
(19, 1, 5, '2023-03-15 12:00:00', '2023-03-15 12:45:00', 2);

COMMIT;
\i setup.sql;

-- Test 2: DR has 1 leg associated; Insert legID = 4. Expected: OK
BEGIN TRANSACTION;
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, source_facility) VALUES
(19, 4, 5, '2023-03-15 12:00:00', '2023-03-15 12:45:00', 2);

COMMIT;
\i setup.sql;

-- Test 3: DR has 1 leg associated; Insert legID = 5. Expected: Error
BEGIN TRANSACTION;
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, source_facility) VALUES
(19, 5, 5, '2023-03-15 12:00:00', '2023-03-15 12:45:00', 2);

COMMIT;
\i setup.sql;

-- Test 4: DR has 1 leg associated; Insert legID = 10. Expected: Error
BEGIN TRANSACTION;
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, source_facility) VALUES
(19, 10, 5, '2023-03-15 12:00:00', '2023-03-15 12:45:00', 2);

COMMIT;
\i setup.sql;