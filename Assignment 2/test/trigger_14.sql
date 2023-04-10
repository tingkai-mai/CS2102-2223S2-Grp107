--q14, SUCCESS
BEGIN TRANSACTION;
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, source_facility) VALUES
(19, 3, 6, '2023-04-02 12:15:00', '2023-04-02 13:00:00', 2);
INSERT INTO unsuccessful_return_deliveries (request_id, leg_id, reason, attempt_time) VALUES
(19, 3, 'Incorrect return address', '2023-04-15 13:00:00');
COMMIT;
\i setup.sql;

-- q14, FAILURE, unsuccessful time = return leg start time
BEGIN TRANSACTION;
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, source_facility) VALUES
(19, 3, 6, '2023-04-02 12:15:00', '2023-04-02 13:00:00', 2);
INSERT INTO unsuccessful_return_deliveries (request_id, leg_id, reason, attempt_time) VALUES
(19, 3, 'Incorrect return address', '2023-04-02 12:15:00');
COMMIT;
\i setup.sql;

--q14, FAILURE, unsuccessful time < return leg start time
BEGIN TRANSACTION;
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, source_facility) VALUES
(19, 3, 6, '2023-04-02 12:15:00', '2023-04-02 13:00:00', 2);
INSERT INTO unsuccessful_return_deliveries (request_id, leg_id, reason, attempt_time) VALUES
(19, 3, 'Incorrect return address', '2023-03-15 13:00:00');
COMMIT;
\i setup.sql;