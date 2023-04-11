-- only one package associated w dr
CALL resubmit_request(15, 5, '2023-03-21 16:45:00', ARRAY[40], ARRAY[40],ARRAY[40],ARRAY[40]);

-- 2 packages associated, all values should be +10 of originally submitted values
-- CALL resubmit_request(19, 5, '2023-03-21 16:45:00', ARRAY[30, 25], ARRAY[25, 20],ARRAY[20, 15],ARRAY[13, 12]);


-- SELECT * FROM packages;
-- SELECT * FROM delivery_requests;
-- Check
-- 1. the exisiting delivery request is marked as cancelled
-- 2. new DR set to submitted