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
    google_id VARCHAR(100) NULL,
    CONSTRAINT pk_users      PRIMARY KEY (user_id),
    CONSTRAINT uq_user_email  UNIQUE (email),
    CONSTRAINT uq_google_id   UNIQUE (google_id)
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

-- --------------------------------------------------------
-- 10. remember_me_tokens
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS remember_me_tokens (
    token      VARCHAR(64) NOT NULL,
    user_id    BIGINT      NOT NULL,
    expires_at DATETIME    NOT NULL,
    CONSTRAINT pk_rmt      PRIMARY KEY (token),
    CONSTRAINT fk_rmt_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 11. driver_schedules  (weekly recurring driver assignments)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS driver_schedules (
    ds_id          BIGINT      NOT NULL AUTO_INCREMENT,
    driver_id      BIGINT      NOT NULL,
    bus_id         BIGINT      NOT NULL,
    route_id       BIGINT      NOT NULL,
    shift_type     VARCHAR(20) NOT NULL,
    shift_start    TIME        NOT NULL,
    shift_end      TIME        NOT NULL,
    week_start_date DATE       NOT NULL,
    published      TINYINT(1)  NOT NULL DEFAULT 0,
    CONSTRAINT pk_driver_schedules      PRIMARY KEY (ds_id),
    CONSTRAINT fk_ds_driver FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    CONSTRAINT fk_ds_bus    FOREIGN KEY (bus_id)    REFERENCES buses(bus_id),
    CONSTRAINT fk_ds_route  FOREIGN KEY (route_id)  REFERENCES routes(route_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- SEED DATA
-- ============================================================
-- NOTE: Passwords below are plain-text for initial seeding convenience.
-- The application automatically re-hashes them to BCrypt (work factor 12)
-- the first time each account successfully logs in.
-- For production, replace with pre-computed BCrypt hashes.
-- ============================================================

-- Single admin account (password: M@sydo123 — auto-migrated to BCrypt on first login)
INSERT IGNORE INTO users (name, email, password, role, status) VALUES
    ('Administrator', 'Maetsok01@gmail.com', 'M@sydo123', 'ADMIN', 'ACTIVE');

-- Drivers (link driver-role users to the drivers table)
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

-- ============================================================
-- TUT / TRIPONZA TEMPLATE SEED DATA
-- Adds the Mon–Fri Soshanguve/Arcadia/Ga-Rankuwa routes,
-- dedicated buses and driver accounts so the admin can
-- immediately create weekly schedule entries.
-- ============================================================

-- TUT Buses (Bus 01–05)
INSERT IGNORE INTO buses (registration_number, capacity) VALUES
    ('BUS-TUT-01', 72),
    ('BUS-TUT-02', 72),
    ('BUS-TUT-03', 72),
    ('BUS-TUT-04', 40),
    ('BUS-TUT-05', 72);

-- TUT Routes (Route 1–15 from the Triponza template)
INSERT IGNORE INTO routes (route_name, start_location, end_location) VALUES
    ('Route 1',  'Soshanguve North Campus', 'Pretoria Campus'),
    ('Route 2',  'Soshanguve South Campus', 'Pretoria Campus'),
    ('Route 3',  'Soshanguve North Campus', 'Arcadia Campus'),
    ('Route 4',  'Ga-Rankuwa Campus',       'Pretoria Campus'),
    ('Route 5',  'Ga-Rankuwa Campus',       'Arcadia Campus'),
    ('Route 6',  'Arcadia Campus',          'Pretoria Campus'),
    ('Route 7',  'Pretoria Campus',         'Arcadia Campus'),
    ('Route 8',  'Arcadia Campus',          'Pretoria Campus'),
    ('Route 9',  'Pretoria Campus',         'Arcadia Campus'),
    ('Route 10', 'Pretoria Campus',         'Soshanguve North Campus'),
    ('Route 11', 'Pretoria Campus',         'Soshanguve South Campus'),
    ('Route 12', 'Arcadia Campus',          'Soshanguve North Campus'),
    ('Route 13', 'Pretoria Campus',         'Ga-Rankuwa Campus'),
    ('Route 14', 'Arcadia Campus',          'Ga-Rankuwa Campus'),
    ('Route 15', 'Pretoria Campus',         'Arcadia Campus');

-- TUT Driver user accounts (Driver A–E; password: driver123 — auto-migrated to BCrypt on first login)
INSERT IGNORE INTO users (name, email, password, role, status) VALUES
    ('Driver A', 'driver.a@triponza.ac.za', 'driver123', 'DRIVER', 'ACTIVE'),
    ('Driver B', 'driver.b@triponza.ac.za', 'driver123', 'DRIVER', 'ACTIVE'),
    ('Driver C', 'driver.c@triponza.ac.za', 'driver123', 'DRIVER', 'ACTIVE'),
    ('Driver D', 'driver.d@triponza.ac.za', 'driver123', 'DRIVER', 'ACTIVE'),
    ('Driver E', 'driver.e@triponza.ac.za', 'driver123', 'DRIVER', 'ACTIVE');

INSERT IGNORE INTO drivers (driver_id, registration_number)
    SELECT user_id, CONCAT('TUT-', LPAD(user_id, 4, '0'))
    FROM users
    WHERE email LIKE '%@triponza.ac.za' AND role = 'DRIVER';

