-- q10, SUCCESS, cancelled time > delivery req time
BEGIN TRANSACTION;
INSERT INTO cancelled_or_unsuccessful_requests (id) VALUES 
(18);
INSERT INTO cancelled_requests VALUES 
(18, '2023-03-26 09:15:00');
COMMIT;
\i setup.sql;

-- q10 FAILURE, date is equal to submitted req date
BEGIN TRANSACTION;
INSERT INTO cancelled_requests VALUES 
(15, '2023-03-30 12:50:00');
COMMIT;
\i setup.sql;

-- q10 FAILURE, date is bef submitted req date
BEGIN TRANSACTION;
INSERT INTO cancelled_requests VALUES 
(15, '2023-03-26 09:15:00');
COMMIT;
\i setup.sql;