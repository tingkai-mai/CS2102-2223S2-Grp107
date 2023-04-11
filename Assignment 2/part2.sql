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
    
    SET CONSTRAINTS trigger_1 DEFERRED;
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
END;
$$ LANGUAGE plpgsql;

CREATE
OR REPLACE PROCEDURE resubmit_request(
    input_req_id INTEGER,
    evaluator_id INTEGER,
    submission_time TIMESTAMP,
    reported_height INTEGER [],
    reported_width INTEGER [],
    reported_depth INTEGER [],
    reported_weight INTEGER []
) AS $$ 
DECLARE
    curs CURSOR FOR (
        SELECT * FROM Packages p 
        WHERE p.request_id = input_req_id 
        ORDER BY package_id 
        ASC);
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
    UPDATE delivery_requests
    SET status = 'cancelled' 
    WHERE id = input_req_id;
    
    -- Create new DR
    SELECT COALESCE(MAX(id), 0) INTO req_id FROM delivery_requests;
    req_id := req_id + 1;
    
    SELECT d.customer_id, d.pickup_addr, d.pickup_postal, d.recipient_name, d.recipient_addr, d.recipient_postal 
    INTO customer_id, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal 
    FROM delivery_requests d WHERE d.id = input_req_id; 
    
    SELECT COUNT(*) INTO package_num FROM Packages p WHERE p.request_id = input_req_id; 

    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        content := array_append(content, r.content);
        estimated_value := array_append(estimated_value, r.estimated_value);
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

$$ LANGUAGE plpgsql;

CREATE
OR REPLACE PROCEDURE insert_leg(
    target_request_id INTEGER,
    handler_id INTEGER,
    start_time TIMESTAMP,
    destination_facility INTEGER
) AS $$ 
DECLARE 
    new_leg_id INT;
BEGIN
    SELECT COALESCE(MAX(L.leg_id), 0) INTO new_leg_id FROM legs L WHERE L.request_id = target_request_id;
    new_leg_id := new_leg_id + 1;

    INSERT INTO legs (
        request_id, 
        leg_id, 
        handler_id, 
        start_time, 
        end_time, 
        destination_facility 
    ) VALUES (
        target_request_id, 
        new_leg_id, 
        handler_id, 
        start_time, 
        NULL, 
        destination_facility 
    );
END;
$$ LANGUAGE plpgsql;

CREATE
OR REPLACE FUNCTION view_trajectory(haha INTEGER) RETURNS TABLE (
    source_addr TEXT,
    destination_addr TEXT,
    start_time TIMESTAMP,
    end_time TIMESTAMP
) AS $$ 
    DECLARE
        flag BOOLEAN;
        prev_r RECORD; 
        next_r RECORD; 
        r RECORD;
        legs_curs SCROLL CURSOR FOR (SELECT * FROM legs l LEFT JOIN facilities f ON l.destination_facility = f.id WHERE haha = l.request_id ORDER BY l.leg_id ASC);
        return_legs_curs SCROLL CURSOR FOR (SELECT * FROM return_legs rl JOIN facilities f ON rl.source_facility = f.id WHERE haha = rl.request_id ORDER BY rl.leg_id ASC);
         
    BEGIN
        -- Loop through legs table
        OPEN legs_curs;
            FETCH FIRST FROM legs_curs INTO r;
            SELECT D.pickup_addr INTO source_addr FROM delivery_requests D WHERE D.id = haha;
            destination_addr := r.address;
            start_time := r.start_time;
            end_time := r.end_time;
            RETURN NEXT;
            prev_r := r;
            LOOP
                FETCH NEXT FROM legs_curs INTO r;
                EXIT WHEN NOT FOUND;
                IF r.destination_facility IS NULL THEN -- Last row in legs. r.address assumed to be NULL if no return legs exist
                    source_addr := prev_r.address;
                    SELECT D.recipient_addr INTO destination_addr FROM delivery_requests D WHERE D.id = haha;
                    start_time := r.start_time; 
                    end_time := r.end_time; 
                ELSE
                    source_addr := prev_r.address;
                    destination_addr := r.address;
                    start_time := r.start_time;
                    end_time := r.end_time;
                END IF; 
                RETURN NEXT;
                prev_r := r;
            END LOOP;
        CLOSE legs_curs;
        
        -- Loop through return_legs table
        OPEN return_legs_curs;
            LOOP
                FETCH return_legs_curs INTO r;
                EXIT WHEN NOT FOUND;
                
                FETCH NEXT FROM return_legs_curs INTO next_r;
                IF NOT FOUND THEN
                    SELECT D.pickup_addr INTO destination_addr FROM delivery_requests D WHERE D.id = haha;
                    source_addr := r.address;
                    start_time := r.start_time;
                    end_time := r.end_time;
                ELSE
                    source_addr := r.address;
                    destination_addr := next_r.address;
                    start_time := r.start_time;
                    end_time := r.end_time; 
                END IF;
                RETURN NEXT;
                FETCH PRIOR FROM return_legs_curs INTO prev_r;
           END LOOP;
        CLOSE return_legs_curs;        
    END;
$$ LANGUAGE plpgsql;

CREATE
OR REPLACE FUNCTION get_top_delivery_persons(k INTEGER) RETURNS TABLE (employee_id INTEGER) AS $$ 
BEGIN
    RETURN QUERY
        SELECT handler_id FROM (
            SELECT handler_id, COUNT(*) as trip_count
            FROM (SELECT handler_id FROM legs
            UNION ALL
            SELECT handler_id FROM return_legs
            UNION ALL
            SELECT handler_id FROM unsuccessful_pickups)
            AS emp_leg_records
            GROUP BY handler_id
            ORDER BY trip_count DESC, handler_id ASC    
        ) AS employee_legs_frequencies
        LIMIT k;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_top_connections(k INTEGER) RETURNS TABLE(
    source_facility_id INTEGER,
    destination_facility_id INTEGER
) AS $$ 
BEGIN
    RETURN QUERY
    WITH cte1 AS (SELECT F1.id AS src, F2.id AS dest
                FROM facilities F1, facilities F2, legs L1, legs L2 
                WHERE L1.destination_facility = F1.id AND
                L2.destination_facility = F2.id AND
                L1.leg_id = L2.leg_id-1 AND
                L1.request_id = L2.request_id),
        cte2 AS (SELECT F1.id AS src, F2.id AS dest
                FROM facilities F1, facilities F2, return_legs R1, return_legs R2
                WHERE R1.source_facility = F1.id AND
                R2.source_facility = F2.id AND
                R1.leg_id = R2.leg_id-1 AND
                R1.request_id = R2.request_id)

    SELECT T1.source_facility_id, T1.destination_facility_id
    FROM 
    (
        SELECT tmp.src AS source_facility_id, 
            tmp.dest AS destination_facility_id, 
            COUNT(*) AS connect_count 
        FROM (SELECT * FROM cte1 
        UNION ALL SELECT * FROM cte2) AS tmp
        GROUP BY tmp.src, tmp.dest
        ORDER BY connect_count DESC, (tmp.src, tmp.dest) ASC
    ) AS T1
    LIMIT k;
END;
$$ LANGUAGE plpgsql;