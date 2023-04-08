INSERT INTO facilities (address, postal) 
VALUES
    ('123 Main St', 'A1B 2C3'),
    ('456 Oak Ave', 'D4E 5F6'),
    ('789 Elm Blvd', 'G7H 8I9'),
    ('1011 Maple Rd', 'J1K 2L3'),
    ('1213 Pine St', 'M4N 5O6');

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility)
VALUES 
    (1, 1, 101, '2023-04-01 10:00:00', '2023-04-01 12:00:00', 1),
    (1, 2, 101, '2023-04-01 13:00:00', '2023-04-01 15:00:00', 2),
    (2, 1, 102, '2023-04-02 09:00:00', '2023-04-02 11:00:00', 3),
    (2, 2, 102, '2023-04-02 12:00:00', '2023-04-02 14:00:00', 4),
    (2, 3, 102, '2023-04-02 15:00:00', '2023-04-02 17:00:00', 5);

INSERT INTO delivery_requests (
	customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price
) 
VALUES (
	1, 2, 'accepted', 'mai address', 'A1B 2C3', 'John Doe', 'wan xuan address', 'D4E 5F6', '2023-04-01 10:00:00', '2023-04-05', 3, 50.00
),
(
	2, 3, 'accepted', 'kai address', 'G7H 8I9', 'Jane Smith', 'qian address', 'J1K 2L3', '2023-04-02 09:00:00', '2023-04-04', 2, 75.00
);

INSERT INTO customers VALUES (1, "mai", 'male', '00000000'), (2, 'kai', 'male', '01010101');

INSERT INTO employees VALUES (
    1,
	'Employee A',
	'male',
	'1999-04-04',
	'delivery man',
	2500
),
(
    2,
	'Employee B',
	'male',
	'1999-04-08',
	'handler',
	2500
),
(
    3,
	'Employee C',
	'male',
	'1999-08-08',
	'delivery man',
	2500
);

INSERT INTO delivery_staff VALUES (
    1
), 
(
    2
);

CALL submit_request(
    1,
    2,
    pickup_addr TEXT,
    pickup_postal TEXT,
    recipient_name TEXT,
    recipient_addr TEXT,
    recipient_postal TEXT,
    submission_time TIMESTAMP,
    package_num INTEGER,
    reported_height INTEGER [],
    reported_width INTEGER [],
    reported_depth INTEGER [],
    reported_weight INTEGER [],
    content TEXT [],
    estimated_value NUMERIC []
);