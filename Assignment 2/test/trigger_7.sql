-- Case 1 [FAILURE]: Start time of leg is before the end time of the previous leg.
BEGIN TRANSACTION;
INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES
(15, 1, 5, '2023-04-29 13:00:00', '2023-04-30 10:30:00', 1),
(15, 2, 5, '2023-04-30 10:00:00', '2023-04-30 10:30:00', 1);

COMMIT;

\i setup.sql;

-- Case 2 [SUCCESS]: Start time of leg is after the end time of the previous leg.
BEGIN TRANSACTION;
INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES
(15, 1, 5, '2023-04-29 10:00:00', '2023-04-29 10:30:00', 1),
(15, 2, 5, '2023-04-30 10:00:00', '2023-04-30 10:30:00', 1);
COMMIT;
\i setup.sql;

-- Case 3 [FAILURE]: End time of the previous leg is NULL.
BEGIN TRANSACTION;
INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES
(15, 1, 5, '2023-04-29 10:00:00', NULL, 1),
(15, 2, 5, '2023-04-30 10:00:00', '2023-04-30 10:30:00', 1);


COMMIT;

\i setup.sql;