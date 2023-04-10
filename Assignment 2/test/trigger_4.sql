-- Delivery Request (15) submission time: 2023-03-30 12:50:00

-- Case 1 [FAILURE]: Timestamp of first unsuccessful pickup is before the submission time of the corresponding delivery request.
BEGIN TRANSACTION;
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(15, 1, 3, '2023-03-05 14:00:00', 'Incorrect address provided');
COMMIT;

\i setup.sql;

-- Case 2 [SUCCESS]: Timestamp of first unsuccessful pickup is after the submission time of the corresponding delivery request.
BEGIN TRANSACTION;
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(15, 1, 3, '2023-04-05 14:00:00', 'Incorrect address provided');
COMMIT;
\i setup.sql;

-- Case 3 [FAILURE]: Timestamp of second unsuccessful pickup is before the previous unsuccessful pickup’s timestamp.
BEGIN TRANSACTION;
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(15, 1, 3, '2023-04-05 14:00:00', 'Incorrect address provided'),
(15, 2, 3, '2023-04-03 14:00:00', 'Incorrect address provided');
COMMIT;

\i setup.sql;

-- Case 4 [SUCCESS]: Timestamp of second unsuccessful pickup is after the previous unsuccessful pickup’s timestamp.
BEGIN TRANSACTION;
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(15, 1, 3, '2023-04-05 14:00:00', 'Incorrect address provided'),
(15, 2, 3, '2023-04-07 14:00:00', 'Incorrect address provided');
COMMIT;

\i setup.sql;
