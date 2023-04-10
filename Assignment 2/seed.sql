\set QUIET on

BEGIN TRANSACTION;
SET CONSTRAINTS trigger_1 DEFERRED; -- defer trigger 1
-- customers
INSERT INTO customers (name, gender, mobile) VALUES
('John Doe', 'male', '123-456-7890'),
('Jane Smith', 'female', '234-567-8901'),
('David Johnson', 'male', '345-678-9012'),
('Mary Williams', 'female', '456-789-0123'),
('Michael Brown', 'male', '567-890-1234'),
('Emily Davis', 'female', '678-901-2345'),
('Christopher Garcia', 'male', '789-012-3456'),
('Emma Martinez', 'female', '890-123-4567'),
('Matthew Rodriguez', 'male', '901-234-5678'),
('Olivia Wilson', 'female', '012-345-6789');

-- employees
INSERT INTO employees (name, gender, dob, title, salary) VALUES
('Peter Parker', 'male', '1990-05-10', 'Manager', 60000),
('Clark Kent', 'male', '1995-03-15', 'Supervisor', 45000),
('Diana Prince', 'female', '1985-06-20', 'Coordinator', 48000),
('Bruce Wayne', 'male', '1980-02-25', 'Executive', 65000),
('Natasha Romanoff', 'female', '1990-07-30', 'Driver', 35000),
('Tony Stark', 'male', '1985-10-05', 'Driver', 35000),
('Steve Rogers', 'male', '1995-12-10', 'Driver', 35000),
('Wanda Maximoff', 'female', '2000-01-15', 'Driver', 35000),
('Sam Wilson', 'male', '1990-03-20', 'Driver', 35000),
('Carol Danvers', 'female', '1985-05-25', 'Driver', 35000);

-- delivery_staff
INSERT INTO delivery_staff (id) VALUES
(1), (2), (3), (4), (5), (6);

-- facilities
INSERT INTO facilities (address, postal) VALUES
('123 Main St', '10001'),
('456 Oak St', '10002'),
('789 Maple St', '10003'),
('111 Elm St', '10004'),
('222 Pine St', '10005'),
('333 Cedar St', '10006'),
('444 Birch St', '10007'),
('555 Walnut St', '10008'),
('666 Cherry St', '10009'),
('777 Chestnut St', '10010');

INSERT INTO delivery_requests (id, customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES
(12, 4, 2, 'submitted', '88 Elm St', '10003', 'Jane Smith', '77 Pine St', '10008', '2023-03-15 10:30:00', '2023-03-16', 1, 10.00),
(13, 5, 1, 'evaluated', '99 Birch St', '10004', 'Alice Johnson', '22 Cedar St', '10007', '2023-03-20 16:45:00', '2023-03-22', 2, 15.00),
(14, 6, 3, 'withdrawn', '44 Willow St', '10005', 'Bob Miller', '66 Palm St', '10009', '2023-03-25 09:15:00', '2023-03-26', 1, 10.00),
(15, 7, 2, 'accepted', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00),
(16, 7, 2, 'completed', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00),
(17, 3, 3, 'completed', '15 Maple St', '10002', 'John Doe', '25 Oak St', '10005', '2023-03-10 14:20:00', '2023-03-12', 2, 15.00),
(18, 6, 3, 'cancelled', '44 Willow St', '10005', 'Bob Miller', '66 Palm St', '10009', '2023-03-25 09:15:00', '2023-03-26', 1, 10.00),
(19, 7, 2, 'unsuccessful', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00);

INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES
(12, 1, 20, 15, 10, 2.5, 'Books', 50, 20, 15, 10, 2.5),
(12, 2, 25, 20, 15, 3.5, 'Clothes', 75, 25, 20, 15, 3.5),
(13, 1, 30, 25, 20, 5.0, 'Electronics', 200, 30, 25, 20, 5.0),
(14, 1, 20, 15, 10, 2.5, 'Toys', 45, 20, 15, 10, 2.5),
(15, 1, 30, 25, 20, 5.0, 'Decorative items', 90, 30, 25, 20, 5.0),
(16, 1, 20, 15, 10, 2.5, 'Shoes', 120, 20, 15, 10, 2.5),
(17, 1, 25, 20, 15, 3.5, 'Stationery', 60, 25, 20, 15, 3.5),
(18, 1, 30, 25, 20, 5.0, 'Tools', 150, 30, 25, 20, 5.0),
(19, 1, 20, 15, 10, 2.5, 'Sports equipment', 100, 20, 15, 10, 2.5);

INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES
(15, '1234567812345678', '2023-03-10 14:25:00', 5),
(16, '2345678923456789', '2023-03-15 10:35:00', 6),
(17, '3456789034567890', '2023-03-20 16:50:00', 7),
(18, '4567890145678901', '2023-03-25 09:20:00', 8),
(19, '5678901256789012', '2023-03-30 12:55:00', 9);

INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES
(15, 1, 1, '2023-03-30 13:00:00', 'Incorrect address provided'),
(16, 1, 2, '2023-03-30 13:00:00', 'No access to the building'),
(17, 1, 3, '2023-03-30 13:00:00', 'Package not ready for pickup'),
(18, 1, 4, '2023-03-30 13:00:00', 'Customer not available');

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES
(15, 1, 5, '2023-03-30 13:05:00', '2023-03-12 13:30:00', 1),
(15, 2, 5, '2023-03-30 13:30:00', '2023-03-12 13:45:00', 2),
(16, 1, 6, '2023-03-30 13:05:00', '2023-03-12 13:30:00', 7),
(16, 2, 6, '2023-03-30 13:30:00', '2023-03-12 13:45:00', 6),
(17, 1, 1, '2023-03-30 13:05:00', '2023-03-12 13:30:00', 1),
(17, 2, 1, '2023-03-30 13:30:00', '2023-03-12 13:45:00', 2),
(18, 1, 2, '2023-03-30 13:05:00', '2023-03-12 13:30:00', 1),
(18, 2, 2, '2023-03-30 13:30:00', '2023-03-12 13:45:00', 2),
(19, 1, 3, '2023-03-30 13:05:00', '2023-03-12 13:30:00', 1),
(19, 2, 3, '2023-03-30 13:30:00', '2023-03-12 13:45:00', 2),
(19, 3, 3, '2023-03-30 13:50:00', '2023-03-12 13:55:00', 2);

-- Ignore this 
-- (16, 1, 6, '2023-03-16 13:05:00', '2023-03-16 09:45:00', 7),
-- (16, 2, 6, '2023-03-16 10:15:00', '2023-03-16 11:00:00', 6);
-- (17, 1, 7, '2023-03-22 08:00:00', '2023-03-22 08:45:00', 1),
-- (17, 2, 7, '2023-03-22 09:15:00', '2023-03-22 10:00:00', 2),
-- (18, 1, 8, '2023-03-26 13:00:00', '2023-03-26 13:45:00', 1),
-- (18, 2, 8, '2023-03-26 14:15:00', '2023-03-26 15:00:00', 2),
-- (19, 1, 9, '2023-04-01 11:00:00', '2023-04-01 11:45:00', 1),
-- (19, 2, 9, '2023-04-01 12:15:00', '2023-04-01 13:00:00', 2),
-- (19, 3, 9, '2023-04-01 13:05:00', '2023-04-01 13:20:00', 2);

INSERT INTO unsuccessful_deliveries (request_id, leg_id, reason, attempt_time) VALUES
(19, 1, 'Recipient not available', '2023-03-31 09:45:00'),
(19, 2, 'Hehe', '2023-03-31 09:45:00'),
(19, 3, 'Haha', '2023-03-31 09:50:00');

INSERT INTO cancelled_or_unsuccessful_requests (id) VALUES 
(19);

-- Cancelled or unsuccessful
-- We only test unsuccessful DR for now
INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, source_facility) VALUES
(19, 1, 5, '2023-03-15 12:00:00', '2023-03-15 12:45:00', 2),
(19, 2, 5, '2023-03-15 13:15:00', '2023-03-15 14:00:00', 1),
(19, 3, 5, '2023-03-20 10:00:00', '2023-03-20 10:45:00', 2);

INSERT INTO unsuccessful_return_deliveries (request_id, leg_id, reason, attempt_time) VALUES
(19, 1, 'Incorrect return address', '2023-03-16 10:00:00'),
(19, 2, 'Return facility closed', '2023-04-16 10:00:00'),
(19, 3, 'Haha', '2023-04-16 10:00:00');

COMMIT;