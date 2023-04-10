-- Delivery_requests related:
-- (1) Each delivery request has at least one package.
-- Insert new package with pkgID = 20
INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES
(20, 1, 20, 15, 10, 2.5, 'Sports equipment', 100, 20, 15, 10, 2.5);

-- Test 1: Insert DR with one package associated
-- Test 2: Insert DR with two package associated
-- Test 3: Insert DR with no package associated