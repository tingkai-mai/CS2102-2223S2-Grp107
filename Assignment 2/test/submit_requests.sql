-- submit_request(
--     customer_id INTEGER,
--     evaluator_id INTEGER,
--     pickup_addr TEXT,
--     pickup_postal TEXT,
--     recipient_name TEXT,
--     recipient_addr TEXT,
--     recipient_postal TEXT,
--     submission_time TIMESTAMP,
--     package_num INTEGER,
--     reported_height INTEGER [],
--     reported_width INTEGER [],
--     reported_depth INTEGER [],
--     reported_weight INTEGER [],
--     content TEXT [],
--     estimated_value NUMERIC []
-- )

CALL submit_request(
    1, 1, '123 Pickup Street', 'P123', 'John Doe', '456 Recipient Road', 'R456', '2023-04-08 09:00:00', 
    2, ARRAY[20, 30], ARRAY[10, 15], ARRAY[15, 25], ARRAY[5, 10], ARRAY['Electronics', 'Clothing'], ARRAY[200.00, 100.00]
);

-- SELECT * FROM packages;
-- SELECT * FROM delivery_requests;

-- CALL submit_request(
--     2, 2, '789 Pickup Street', 'P789', 'Jane Smith', '963 Recipient Road', 'R963', '2023-04-08 10:00:00', 
--     1, ARRAY[40], ARRAY[20], ARRAY[20], ARRAY[15], ARRAY['Books'], ARRAY[75.00]
-- );

-- CALL submit_request(
--     3, 3, '246 Pickup Street', 'P246', 'Emily Johnson', '135 Recipient Road', 'R135', '2023-04-08 11:00:00', 
--     3, ARRAY[25, 35, 45], ARRAY[15, 20, 25], ARRAY[15, 20, 25], ARRAY[10, 20, 30], ARRAY['Home Decor', 'Kitchenware', 'Toys'], ARRAY[150.00, 125.00, 50.00]
-- );
