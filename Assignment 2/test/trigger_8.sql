--q8 SUCCESS
BEGIN TRANSACTION;
INSERT INTO unsuccessful_deliveries (request_id, leg_id, reason, attempt_time) VALUES
(19, 2, 'Recipient not available', '2023-04-01 11:40:00'),
(19, 3, 'Hehe', '2023-04-01 13:45:00');
COMMIT;

\i setup.sql;

-- q8, FAILURE, time inserted = leg start time
BEGIN TRANSACTION;
INSERT INTO unsuccessful_deliveries (request_id, leg_id, reason, attempt_time) VALUES 
(19, 2, 'Haha', '2023-03-30 13:30:00');
COMMIT;

\i setup.sql;

-- q8, FAILURE, time inserted < leg start time
BEGIN TRANSACTION;

INSERT INTO unsuccessful_deliveries (request_id, leg_id, reason, attempt_time) VALUES 
(19, 2, 'Haha', '2023-03-01 13:20:00');
COMMIT;

\i setup.sql;

