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
(5), (6), (7), (8), (9), (10);

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
(11, 3, 3, 'completed', '15 Maple St', '10002', 'John Doe', '25 Oak St', '10005', '2023-03-10 14:20:00', '2023-03-12', 2, 15.00),
(12, 4, 2, 'completed', '88 Elm St', '10003', 'Jane Smith', '77 Pine St', '10008', '2023-03-15 10:30:00', '2023-03-16', 1, 10.00),
(13, 5, 1, 'completed', '99 Birch St', '10004', 'Alice Johnson', '22 Cedar St', '10007', '2023-03-20 16:45:00', '2023-03-22', 2, 15.00),
(14, 6, 3, 'completed', '44 Willow St', '10005', 'Bob Miller', '66 Palm St', '10009', '2023-03-25 09:15:00', '2023-03-26', 1, 10.00),
(15, 7, 2, 'completed', '77 Cherry St', '10006', 'Carol Jackson', '11 Maple St', '10010', '2023-03-30 12:50:00', '2023-04-01', 2, 15.00);

INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES
(11, '1234567812345678', '2023-03-10 14:25:00', 5),
(12, '2345678923456789', '2023-03-15 10:35:00', 6),
(13, '3456789034567890', '2023-03-20 16:50:00', 7),
(14, '4567890145678901', '2023-03-25 09:20:00', 8),
(15, '5678901256789012', '2023-03-30 12:55:00', 9);

INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility) VALUES
(11, 1, 2, '2023-03-12 10:00:00', '2023-03-12 10:30:00', 1),
(11, 2, 2, '2023-03-12 11:00:00', '2023-03-12 11:45:00', 2),
(12, 1, 3, '2023-03-16 09:00:00', '2023-03-16 09:45:00', 1),
(12, 2, 3, '2023-03-16 10:15:00', '2023-03-16 11:00:00', 2),
(13, 1, 4, '2023-03-22 08:00:00', '2023-03-22 08:45:00', 1),
(13, 2, 4, '2023-03-22 09:15:00', '2023-03-22 10:00:00', 2),
(14, 1, 5, '2023-03-26 13:00:00', '2023-03-26 13:45:00', 1),
(14, 2, 5, '2023-03-26 14:15:00', '2023-03-26 15:00:00', 2),
(15, 1, 6, '2023-04-01 11:00:00', '2023-04-01 11:45:00', 1),
(15, 2, 6, '2023-04-01 12:15:00', '2023-04-01 13:00:00', 2);

INSERT INTO unsuccessful_deliveries (request_id, reason) VALUES
(16, 'Recipient not available'),
(17, 'Incorrect address'),
(18, 'Damaged package');

INSERT INTO return_legs (request_id, leg_id, handler_id, start_time, end_time, origin_facility) VALUES
(16, 1, 2, '2023-03-15 12:00:00', '2023-03-15 12:45:00', 2),
(16, 2, 2, '2023-03-15 13:15:00', '2023-03-15 14:00:00', 1),
(17, 1, 3, '2023-03-20 10:00:00', '2023-03-20 10:45:00', 2),
(17, 2, 3, '2023-03-20 11:15:00', '2023-03-20 12:00:00', 1),
(18, 1, 4, '2023-03-25 14:00:00', '2023-03-25 14:45:00', 2),
(18, 2, 4, '2023-03-25 15:15:00', '2023-03-25 16:00:00', 1);

INSERT INTO unsuccessful_return_deliveries (request_id, reason) VALUES
(19, 'Incorrect return address'),
(20, 'Return facility closed');


