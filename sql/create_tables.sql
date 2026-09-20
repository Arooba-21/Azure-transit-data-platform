-- Public Transportation Data Platform — Table Definitions
-- Run in Azure SQL Database (db_transit)

CREATE TABLE routes (
    route_id NVARCHAR(20) PRIMARY KEY,
    route_name NVARCHAR(100),
    route_type NVARCHAR(20),
    total_stops INT
);

CREATE TABLE stops (
    stop_id NVARCHAR(10) PRIMARY KEY,
    stop_name NVARCHAR(200)
);

CREATE TABLE stop_times (
    route_id NVARCHAR(20),
    stop_sequence INT,
    stop_id NVARCHAR(10),
    stop_name NVARCHAR(200),
    delay_minutes INT
);
