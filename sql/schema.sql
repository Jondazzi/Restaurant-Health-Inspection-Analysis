CREATE DATABASE la_restaurant_inspections;
SELECT current_database();

CREATE TABLE inspections (
    activity_date DATE,
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
    service_code INT,
    service_description VARCHAR(255),
    score VARCHAR(50),
    grade VARCHAR(5),
    serial_number VARCHAR(50) PRIMARY KEY, -- Unique ID linking both tables
    employee_id VARCHAR(50)
);

CREATE TABLE violations (
    serial_number VARCHAR(50) REFERENCES inspections(serial_number),
    violation_status VARCHAR(50),
    violation_code VARCHAR(50),
    violation_description TEXT
);
ALTER TABLE inspections ADD COLUMN object_id INTEGER;
ALTER TABLE violations ADD COLUMN points VARCHAR(25);
ALTER TABLE violations DROP CONSTRAINT violations_serial_number_fkey;

SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

