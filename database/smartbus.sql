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
-- 6. bus_stops  (GPS-coordinates for physical boarding stops)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS bus_stops (
    stop_id   BIGINT       NOT NULL AUTO_INCREMENT,
    stop_name VARCHAR(150) NOT NULL,
    latitude  DOUBLE,
    longitude DOUBLE,
    CONSTRAINT pk_bus_stops PRIMARY KEY (stop_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 6a. stop_routes  (many-to-many: bus_stops <-> routes)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS stop_routes (
    stop_id  BIGINT NOT NULL,
    route_id BIGINT NOT NULL,
    CONSTRAINT pk_stop_routes PRIMARY KEY (stop_id, route_id),
    CONSTRAINT fk_sr_stop  FOREIGN KEY (stop_id)  REFERENCES bus_stops(stop_id) ON DELETE CASCADE,
    CONSTRAINT fk_sr_route FOREIGN KEY (route_id) REFERENCES routes(route_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 7. trips
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
-- 10. password_reset_tokens
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id      BIGINT      NOT NULL AUTO_INCREMENT,
    user_id BIGINT      NOT NULL,
    token   VARCHAR(64) NOT NULL,
    expiry  DATETIME    NOT NULL,
    CONSTRAINT pk_prt       PRIMARY KEY (id),
    CONSTRAINT uq_prt_token UNIQUE (token),
    CONSTRAINT fk_prt_user  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 11. remember_me_tokens
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS remember_me_tokens (
    token      VARCHAR(64) NOT NULL,
    user_id    BIGINT      NOT NULL,
    expires_at DATETIME    NOT NULL,
    CONSTRAINT pk_rmt      PRIMARY KEY (token),
    CONSTRAINT fk_rmt_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 12. driver_schedules  (weekly recurring driver assignments)
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
-- Single admin account (password: M@sydo123 — auto-migrated to BCrypt on first login)
INSERT IGNORE INTO users (name, email, password, role, status) VALUES
    ('Administrator', 'Maetsok01@gmail.com', 'M@sydo123', 'ADMIN', 'ACTIVE');

