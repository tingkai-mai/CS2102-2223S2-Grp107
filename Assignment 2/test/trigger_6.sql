-- Case 1 [FAILURE]: Start time of first leg is before the submission time of the corresponding delivery request. (NO UNSUCCESSFUL PICKUPS)
BEGIN TRANSACTION;
INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES
(15, 1, 5, '2023-03-29 10:00:00', '2023-03-31 10:30:00', 1);
COMMIT;

\i setup.sql;

-- Case 2 [SUCCESS]: Start time of first leg is after the submission time of the corresponding delivery request. (NO UNSUCCESSFUL PICKUPS)
BEGIN TRANSACTION;
INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES
(15, 1, 5, '2023-04-12 10:00:00', '2023-04-12 10:30:00', 1);

COMMIT;
\i setup.sql;

-- Case 3 [FAILURE]: Start time of first leg is before the timestamp of the last unsuccessful pickup. (HAVE UNSUCCESSFUL PICKUPS)
BEGIN TRANSACTION;
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(15, 1, 3, '2023-04-05 14:00:00', 'Incorrect address provided'),
(15, 2, 3, '2023-04-07 14:00:00', 'Incorrect address provided');
INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES
(15, 1, 5, '2023-04-06 10:00:00', '2023-04-08 10:30:00', 1);

COMMIT;

\i setup.sql;

-- Case 4 [SUCCESS]: Start time of first leg is after the timestamp of the last unsuccessful pickup. (HAVE UNSUCCESSFUL PICKUPS)
BEGIN TRANSACTION;
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(15, 1, 3, '2023-04-05 14:00:00', 'Incorrect address provided'),
(15, 2, 3, '2023-04-07 14:00:00', 'Incorrect address provided');
INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES
(15, 1, 5, '2023-04-08 10:00:00', '2023-04-08 10:30:00', 1);

COMMIT;

\i setup.sql;
