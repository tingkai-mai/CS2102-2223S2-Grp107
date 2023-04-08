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
END;
$$ LANGUAGE plpgsql;

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
    curs CURSOR FOR (
        SELECT * FROM Packages p 
        WHERE p.request_id = request_id 
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
$$ LANGUAGE plpgsql;

CREATE
OR REPLACE FUNCTION view_trajectory(request_id INTEGER) RETURNS TABLE (
    source_addr TEXT,
    destination_addr TEXT,
    start_time TIMESTAMP,
    end_time TIMESTAMP
) AS $$ 
    DECLARE
        prev_r RECORD;
        next_r RECORD; 
        r RECORD;
        legs_curs CURSOR FOR (SELECT * FROM legs l JOIN facilities f ON l.destination_facility = f.id WHERE request_id = l.request_id);
        return_legs_curs CURSOR FOR (SELECT * FROM return_legs r JOIN facilities f ON r.source_facility = f.id WHERE request_id = r.request_id);
        
    BEGIN
        -- Loop through legs table
        OPEN legs_curs;
            LOOP
                FETCH legs_curs INTO r;
                EXIT WHEN NOT FOUND;
                FETCH PRIOR FROM legs_curs INTO prev_r;
                
                IF NOT FOUND THEN
                    SELECT D.pickup_addr INTO source_addr FROM delivery_requests D WHERE D.id = request_id;
                    destination_addr := r.address;
                    start_time := r.start_time;
                    end_time := r.end_time;
                ELSE 
                    FETCH NEXT FROM legs_curs INTO r;
                    IF r.address IS NULL THEN -- Last row in legs. r.address assumed to be NULL if no return legs exist
                        source_addr := prev_r.address;
                        SELECT D.recipient_addr INTO destination_addr FROM delivery_requests D WHERE D.id = request_id;
                        start_time := r.start_time;
                        end_time := r.end_time; 
                    ELSE
                        source_addr := prev_r.address;
                        destination_addr := r.address;
                        start_time := r.start_time;
                        end_time := r.end_time;
                    END IF;
                END IF;
                
                RETURN NEXT;
                FETCH NEXT FROM legs_curs INTO r;
            END LOOP;
        CLOSE legs_curs;
        
        -- Loop through return_legs table
        OPEN return_legs_curs;
            LOOP
                FETCH return_legs_curs INTO r;
                EXIT WHEN NOT FOUND;
                FETCH NEXT FROM return_legs_curs INTO next_r;
                IF NOT FOUND THEN
                    SELECT D.recipient_addr INTO destination_addr FROM delivery_requests D WHERE D.id = request_id;
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
           END LOOP;
        CLOSE return_legs_curs;        
    END;
$$ LANGUAGE plpgsql;

CREATE
OR REPLACE FUNCTION get_top_delivery_persons(k INTEGER) RETURNS TABLE (employee_id INTEGER) AS $$ 
BEGIN
    RETURN QUERY
        -- Check if after group by, will the count become 1 for each group
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

-- SELECT handler_id
-- FROM
-- (
-- SELECT l1.handler_id, 
-- ( (SELECT COUNT(*) FROM legs l1 WHERE l1.handler_id = l.handler_id GROUP BY l1.handler_id) +
-- (SELECT COUNT(*) FROM return_legs r WHERE r.handler_id = l.handler_id GROUP BY r.handler_id) + 
-- (SELECT COUNT(*) FROM unsuccessful_pickups u WHERE u.handler_id = l.handler_id GROUP BY u.handler_id) ) AS TOTAL_COUNT 
-- FROM legs l
-- )
-- ORDER BY TOTAL_COUNT DESC
-- LIMIT K


CREATE
OR REPLACE FUNCTION get_top_connections(k INTEGER) RETURNS TABLE(
    source_facility_id INTEGER,
    destination_facility_id INTEGER
) AS $$ 
BEGIN
    RETURN QUERY
    WITH cte1 AS (SELECT F1.id, F2.id, L1.leg_id, L2.leg_id
                FROM facilities F1, facilities F2, legs L1, legs L2 
                WHERE L1.destination_facility = F1.id AND
                L2.destination_facility = F2.id AND
                F1.id <> F2.id AND
                L1.leg_id = L2.leg_id-1 AND
                L1.request_id = L2.request_id),
        cte2 AS (SELECT F1.id, F2.id, R1.leg_id, R2.leg_id
                FROM facilities F1, facilities F2, return_legs R1, return_legs R2
                WHERE R1.destination_facility = F1.id AND
                R2.destination_facility = F2.id AND
                R1.leg_id = R2.leg_id-1 AND
                R1.request_id = R2.request_id)

    SELECT T1.source_facility_id, T1.destination_facility_id
    FROM 
    (
        SELECT F1.id AS source_facility_id, 
            F2.id AS destination_facility_id, 
            COUNT(*) AS connect_count 
        FROM (SELECT * FROM cte1 
        UNION ALL SELECT * FROM cte2) AS tmp
        GROUP BY F1.id, F2.id
        ORDER BY connect_count
        
    ) AS T1
    LIMIT k;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_top_connections(k INTEGER)
RETURNS TABLE(
    source_facility_id INTEGER,
    destination_facility_id INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT source_facility_id, destination_facility_id
    FROM (
        SELECT l.source_facility_id, l.destination_facility_id, COUNT(*) AS cnt
        FROM (
            SELECT l1.request_id, l1.destination_facility AS source_facility_id, l2.destination_facility AS destination_facility_id
            FROM legs l1
            JOIN legs l2 ON l1.request_id = l2.request_id AND l1.leg_id + 1 = l2.leg_id
            UNION ALL
            SELECT r1.request_id, r1.source_facility AS source_facility_id, r2.source_facility AS destination_facility_id
            FROM return_legs r1
            JOIN return_legs r2 ON r1.request_id = r2.request_id AND r1.leg_id + 1 = r2.leg_id
        ) AS l
        GROUP BY l.source_facility_id, l.destination_facility_id
    ) AS t
    ORDER BY cnt DESC, source_facility_id ASC, destination_facility_id ASC
    LIMIT k;
END;
$$ LANGUAGE plpgsql;
