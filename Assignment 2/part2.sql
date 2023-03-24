CREATE
OR REPLACE PROCEDURE submit_request(
    customer_id INTEGER,
    evaluator_id INTEGER,
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
) AS $$ 
DECLARE 
    req_id INTEGER;
BEGIN
    SELECT COALESCE(MAX(id), 0) INTO req_id FROM delivery_requests;
    req_id := req_id + 1;
    
    BEGIN TRANSACTION 
        SET CONSTRAINTS constraint_delivery_request_has_package DEFERRED;
        INSERT INTO delivery_requests VALUES (req_id, customer_id, evaluator_id, 'submitted', pickup_addr, pickup_postal, recipient_name,
        recipient_addr, recipient_postal, submission_time, NULL, NULL, NULL);
        FOR i IN 1..package_num LOOP
            INSERT INTO packages (
            request_id, package_id, reported_height, reported_width, reported_depth,
            reported_weight, content, estimated_value
            )
            VALUES (
            req_id, i, reported_height[i], reported_width[i], reported_depth[i],
            reported_weight[i], content[i], estimated_value[i]
            );
        END LOOP;
    COMMIT;    
END;
$$ LANGUAGE SQL;

CREATE
OR REPLACE PROCEDURE resubmit_request(
    request_id INTEGER,
    evaluator_id INTEGER,
    submission_time TIMESTAMP,
    reported_height INTEGER [],
    reported_width INTEGER [],
    reported_depth INTEGER [],
    reported_weight INTEGER []
) AS $$ 
DECLARE
    curs CURSOR FOR (SELECT * FROM Packages p WHERE p.request_id = request_id ORDER BY package_id);
    r RECORD;
    req_id INT;
    customer_id INT;
    pickup_addr TEXT;
    pickup_postal TEXT;
    recipient_name TEXT;
    recipient_addr TEXT;
    recipient_postal TEXT;
    package_num INT;
    content TEXT[];
    estimated_value NUMERIC[];
BEGIN
    -- Update old DR
    UPDATE delivery_requests d 
    SET delivery_status = 'cancelled' 
    WHERE d.id = request_id;
    
    -- Create new DR
    SELECT COALESCE(MAX(id), 0) INTO req_id FROM delivery_requests;
    req_id := req_id + 1;
    
    SELECT d.customer_id, d.pickup_addr, d.pickup_postal, d.recipient_name, d.recipient_addr, d.recipient_postal 
    INTO customer_id, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal 
    FROM delivery_requests d WHERE d.id = request_id; 
    
    SELECT COUNT(*) INTO package_num FROM Packages p WHERE p.request_id = request_id; 

    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        ARRAY_APPEND(content, r.content);
        ARRAY_APPEND(estimated_value, r.estimated_value);
    END LOOP;
    CLOSE curs;
    
    -- Create new DR
    CALL submit_request(
        customer_id,
        evaluator_id,
        pickup_addr,
        pickup_postal,
        recipient_name,
        recipient_addr,
        recipient_postal,
        submission_time,
        package_num,
        reported_height,
        reported_width,
        reported_depth,
        reported_weight,
        content,
        estimated_value
    );

END;

$$ LANGUAGE SQL;

CREATE
OR REPLACE PROCEDURE insert_leg(
    request_id INTEGER,
    handler_id INTEGER,
    start_time TIMESTAMP,
    destination_facility INTEGER
) AS $$ 
DECLARE 
    leg_id INT;
BEGIN
    SELECT COALESCE(MAX(leg_id), 0) INTO leg_id FROM legs L WHERE L.request_id = request_id;
    leg_id := leg_id + 1;

    INSERT INTO legs (
        request_id, 
        leg_id, 
        handler_id, 
        start_time, 
        end_time, 
        destination_facility 
    ) VALUES (
        request_id, 
        leg_id, 
        handler_id, 
        start_time, 
        NULL, 
        destination_facility 
    );
END;
$$ LANGUAGE SQL;

CREATE
OR REPLACE FUNCTION view_trajectory(request_id INTEGER) RETURNS TABLE (
    source_addr TEXT,
    destination_addr TEXT,
    start_time TIMESTAMP,
    end_time TIMESTAMP
) AS $$ $$ LANGUAGE plpgsql;
 loveloyou adi
CREATE
OR REPLACE FUNCTION get_top_delivery_persons(k INTEGER) RETURNS TABLE (employee_id INTEGER) AS $$ $$ LANGUAGE plpgsql;

CREATE
OR REPLACE FUNCTION get_top_connections(k INTEGER) RETURNS TABLE(
    source_facility_id INTEGER,
    destination_facility_id INTEGER
) AS $$ $$ LANGUAGE plpgsql;