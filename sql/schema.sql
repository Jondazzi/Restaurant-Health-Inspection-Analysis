CREATE DATABASE la_restaurant_inspections;
SELECT current_database();

CREATE TABLE IF NOT EXISTS inspections (
    activity_date TIMESTAMP WITH TIME ZONE,
    owner_id VARCHAR(50),
    owner_name VARCHAR(255),
    facility_id VARCHAR(50),
    facility_name VARCHAR(255),
    record_id VARCHAR(50),
    program_name VARCHAR(255),
    program_status VARCHAR(50),
    program_element VARCHAR(50),
    pe_description VARCHAR(255),
    facility_address VARCHAR(255),
    facility_city VARCHAR(100),
    facility_state VARCHAR(10),
    facility_zip VARCHAR(20),
    service_code INTEGER,
    service_description VARCHAR(255),
    score INTEGER,
    grade VARCHAR(5),
    serial_number VARCHAR(50) PRIMARY KEY,
    employee_id VARCHAR(50),
    object_id INTEGER
);

CREATE TABLE IF NOT EXISTS violations (
    serial_number VARCHAR(50),
    violation_status VARCHAR(50),
    violation_code VARCHAR(50),
    violation_description TEXT,
    points NUMERIC
);