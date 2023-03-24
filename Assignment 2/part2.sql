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
) AS $$ BEGIN
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
) AS $$ BEGIN
END;

$$ LANGUAGE SQL;

CREATE
OR REPLACE PROCEDURE insert_leg(
    request_id INTEGER,
    handler_id INTEGER,
    start_time TIMESTAMP,
    destination_facility INTEGER
) AS $$ BEGIN
END;

$$ LANGUAGE SQL;

CREATE
OR REPLACE FUNCTION view_trajectory(request_id INTEGER) RETURNS TABLE (
    source_addr TEXT,
    destination_addr TEXT,
    start_time TIMESTAMP,
    end_time TIMESTAMP
) AS $$ $$ LANGUAGE plpgsql;

CREATE
OR REPLACE FUNCTION get_top_delivery_persons(k INTEGER) RETURNS TABLE (employee_id INTEGER) AS $$ $$ LANGUAGE plpgsql;

CREATE
OR REPLACE FUNCTION get_top_connections(k INTEGER) RETURNS TABLE(
    source_facility_id INTEGER,
    destination_facility_id INTEGER
) AS $$ $$ LANGUAGE plpgsql;