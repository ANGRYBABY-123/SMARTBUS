-- ============================================================
-- SmartBus System – Database Setup Script
-- MySQL 8.x
-- Run this script BEFORE first deployment (or let Hibernate
-- auto-create tables via hbm2ddl.auto=update).
-- ============================================================

CREATE DATABASE IF NOT EXISTS smartbus
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE smartbus;

-- --------------------------------------------------------
-- 1. users (base table – JOINED inheritance)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    user_id   BIGINT       NOT NULL AUTO_INCREMENT,
    name      VARCHAR(100) NOT NULL,
    email     VARCHAR(150) NOT NULL,
    password  VARCHAR(255) NOT NULL,
    role      VARCHAR(20)  NOT NULL,
    status    VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT pk_users     PRIMARY KEY (user_id),
    CONSTRAINT uq_user_email UNIQUE (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 2. passengers
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS passengers (
    passenger_id BIGINT       NOT NULL,
    email        VARCHAR(150),
    CONSTRAINT pk_passengers   PRIMARY KEY (passenger_id),
    CONSTRAINT fk_passenger_user FOREIGN KEY (passenger_id)
        REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 3. drivers
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS drivers (
    driver_id           BIGINT      NOT NULL,
    registration_number VARCHAR(50) NOT NULL,
    CONSTRAINT pk_drivers       PRIMARY KEY (driver_id),
    CONSTRAINT uq_driver_reg    UNIQUE (registration_number),
    CONSTRAINT fk_driver_user   FOREIGN KEY (driver_id)
        REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 4. buses
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS buses (
    bus_id              BIGINT      NOT NULL AUTO_INCREMENT,
    registration_number VARCHAR(50) NOT NULL,
    capacity            INT         NOT NULL,
    CONSTRAINT pk_buses    PRIMARY KEY (bus_id),
    CONSTRAINT uq_bus_reg  UNIQUE (registration_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 5. routes
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS routes (
    route_id       BIGINT       NOT NULL AUTO_INCREMENT,
    route_name     VARCHAR(100) NOT NULL,
    start_location VARCHAR(150) NOT NULL,
    end_location   VARCHAR(150) NOT NULL,
    CONSTRAINT pk_routes PRIMARY KEY (route_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 6. trips
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS trips (
    trip_id    BIGINT      NOT NULL AUTO_INCREMENT,
    driver_id  BIGINT      NOT NULL,
    bus_id     BIGINT      NOT NULL,
    route_id   BIGINT      NOT NULL,
    start_time DATETIME,
    end_time   DATETIME,
    status     VARCHAR(20),
    CONSTRAINT pk_trips        PRIMARY KEY (trip_id),
    CONSTRAINT fk_trip_driver  FOREIGN KEY (driver_id)  REFERENCES drivers(driver_id),
    CONSTRAINT fk_trip_bus     FOREIGN KEY (bus_id)     REFERENCES buses(bus_id),
    CONSTRAINT fk_trip_route   FOREIGN KEY (route_id)   REFERENCES routes(route_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 7. gps_tracking
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS gps_tracking (
    tracking_id BIGINT         NOT NULL AUTO_INCREMENT,
    trip_id     BIGINT         NOT NULL,
    latitude    DOUBLE         NOT NULL,
    longitude   DOUBLE         NOT NULL,
    timestamp   DATETIME       NOT NULL,
    CONSTRAINT pk_gps        PRIMARY KEY (tracking_id),
    CONSTRAINT fk_gps_trip   FOREIGN KEY (trip_id) REFERENCES trips(trip_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 8. schedules
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS schedules (
    schedule_id    BIGINT NOT NULL AUTO_INCREMENT,
    route_id       BIGINT NOT NULL,
    departure_time TIME   NOT NULL,
    arrival_time   TIME   NOT NULL,
    CONSTRAINT pk_schedules       PRIMARY KEY (schedule_id),
    CONSTRAINT fk_schedule_route  FOREIGN KEY (route_id) REFERENCES routes(route_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 9. notifications
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS notifications (
    notification_id BIGINT      NOT NULL AUTO_INCREMENT,
    user_id         BIGINT      NOT NULL,
    trip_id         BIGINT      NULL,
    message         TEXT        NOT NULL,
    type            VARCHAR(50),
    is_read         TINYINT(1)  NOT NULL DEFAULT 0,
    timestamp       DATETIME    NOT NULL,
    CONSTRAINT pk_notifications       PRIMARY KEY (notification_id),
    CONSTRAINT fk_notification_user   FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_notif_trip          FOREIGN KEY (trip_id) REFERENCES trips(trip_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- SEED DATA
-- ============================================================

-- Admin user (password: admin123)
INSERT IGNORE INTO users (name, email, password, role, status) VALUES
    ('Admin User',    'admin@smartbus.com',   'admin123',   'ADMIN',     'ACTIVE'),
    ('John Driver',   'john@smartbus.com',    'driver123',  'DRIVER',    'ACTIVE'),
    ('Alice Driver',  'alice@smartbus.com',   'driver123',  'DRIVER',    'ACTIVE'),
    ('Bob Passenger', 'bob@smartbus.com',     'pass123',    'PASSENGER', 'ACTIVE'),
    ('Eve Passenger', 'eve@smartbus.com',     'pass123',    'PASSENGER', 'ACTIVE');

-- Drivers (link to user rows 2 and 3)
INSERT IGNORE INTO drivers (driver_id, registration_number)
    SELECT user_id, CONCAT('DRV-', LPAD(user_id, 4, '0'))
    FROM users WHERE role = 'DRIVER';

-- Passengers
INSERT IGNORE INTO passengers (passenger_id, email)
    SELECT user_id, email FROM users WHERE role = 'PASSENGER';

-- Buses
INSERT IGNORE INTO buses (registration_number, capacity) VALUES
    ('BUS-001', 50), ('BUS-002', 40), ('BUS-003', 60);

-- Routes
INSERT IGNORE INTO routes (route_name, start_location, end_location) VALUES
    ('Route A', 'Central Station', 'Airport'),
    ('Route B', 'North Terminal',  'South Terminal'),
    ('Route C', 'East Side',       'West Side');

-- Schedules
INSERT IGNORE INTO schedules (route_id, departure_time, arrival_time) VALUES
    (1, '06:00:00', '07:00:00'),
    (1, '09:00:00', '10:00:00'),
    (2, '07:30:00', '08:30:00'),
    (3, '08:00:00', '09:15:00');

-- Trips
INSERT IGNORE INTO trips (driver_id, bus_id, route_id, start_time, status)
    SELECT d.driver_id, 1, 1, NOW(), 'SCHEDULED'
    FROM drivers d LIMIT 1;
