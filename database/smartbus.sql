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

-- ============================================================
-- CLEANUP: drop orphan plural / duplicate tables left behind
-- by earlier Hibernate auto-create runs.
-- Safe to run repeatedly (IF EXISTS).
-- ============================================================
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS passengers;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS routes;
DROP TABLE IF EXISTS trips;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS schedules;
DROP TABLE IF EXISTS stop_routes;
DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS remember_me_tokens;
SET FOREIGN_KEY_CHECKS = 1;
-- ============================================================

-- --------------------------------------------------------
-- 1. user (base table – JOINED inheritance)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS user (
    user_id      BIGINT       NOT NULL AUTO_INCREMENT,
    name         VARCHAR(100) NOT NULL,
    email        VARCHAR(150) NOT NULL,
    password     VARCHAR(255) NOT NULL,
    role         VARCHAR(20)  NOT NULL,
    status       VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
    google_id    VARCHAR(100) NULL,
    phone_number VARCHAR(20)  NULL,
    CONSTRAINT pk_user       PRIMARY KEY (user_id),
    CONSTRAINT uq_user_email  UNIQUE (email),
    CONSTRAINT uq_google_id   UNIQUE (google_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 2. passenger
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS passenger (
    passenger_id BIGINT       NOT NULL,
    email        VARCHAR(150),
    CONSTRAINT pk_passenger     PRIMARY KEY (passenger_id),
    CONSTRAINT fk_passenger_user FOREIGN KEY (passenger_id)
        REFERENCES user(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 3. driver
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS driver (
    driver_id           BIGINT      NOT NULL,
    registration_number VARCHAR(50) NOT NULL,
    CONSTRAINT pk_driver        PRIMARY KEY (driver_id),
    CONSTRAINT uq_driver_reg    UNIQUE (registration_number),
    CONSTRAINT fk_driver_user   FOREIGN KEY (driver_id)
        REFERENCES user(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 4. bus
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS bus (
    bus_id              BIGINT      NOT NULL AUTO_INCREMENT,
    registration_number VARCHAR(50) NOT NULL,
    capacity            INT         NOT NULL,
    CONSTRAINT pk_bus      PRIMARY KEY (bus_id),
    CONSTRAINT uq_bus_reg  UNIQUE (registration_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 5. route
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS route (
    route_id       BIGINT       NOT NULL AUTO_INCREMENT,
    route_name     VARCHAR(100) NOT NULL,
    start_location VARCHAR(150) NOT NULL,
    end_location   VARCHAR(150) NOT NULL,
    CONSTRAINT pk_route PRIMARY KEY (route_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 6. trip
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS trip (
    trip_id    BIGINT      NOT NULL AUTO_INCREMENT,
    driver_id  BIGINT      NOT NULL,
    bus_id     BIGINT      NOT NULL,
    route_id   BIGINT      NOT NULL,
    start_time DATETIME,
    end_time   DATETIME,
    status     VARCHAR(20),
    CONSTRAINT pk_trip         PRIMARY KEY (trip_id),
    CONSTRAINT fk_trip_driver  FOREIGN KEY (driver_id)  REFERENCES driver(driver_id),
    CONSTRAINT fk_trip_bus     FOREIGN KEY (bus_id)     REFERENCES bus(bus_id),
    CONSTRAINT fk_trip_route   FOREIGN KEY (route_id)   REFERENCES route(route_id)
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
    CONSTRAINT fk_gps_trip   FOREIGN KEY (trip_id) REFERENCES trip(trip_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 8. schedule
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS schedule (
    schedule_id    BIGINT NOT NULL AUTO_INCREMENT,
    route_id       BIGINT NOT NULL,
    departure_time TIME   NOT NULL,
    arrival_time   TIME   NOT NULL,
    CONSTRAINT pk_schedule        PRIMARY KEY (schedule_id),
    CONSTRAINT fk_schedule_route  FOREIGN KEY (route_id) REFERENCES route(route_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 9. notification
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS notification (
    notification_id BIGINT      NOT NULL AUTO_INCREMENT,
    user_id         BIGINT      NOT NULL,
    trip_id         BIGINT      NULL,
    message         TEXT        NOT NULL,
    type            VARCHAR(50),
    is_read         TINYINT(1)  NOT NULL DEFAULT 0,
    timestamp       DATETIME    NOT NULL,
    CONSTRAINT pk_notification        PRIMARY KEY (notification_id),
    CONSTRAINT fk_notification_user   FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_notif_trip          FOREIGN KEY (trip_id) REFERENCES trip(trip_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 10. password_reset_token
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS password_reset_token (
    id      BIGINT      NOT NULL AUTO_INCREMENT,
    user_id BIGINT      NOT NULL,
    token   VARCHAR(64) NOT NULL,
    expiry  DATETIME    NOT NULL,
    CONSTRAINT pk_prt       PRIMARY KEY (id),
    CONSTRAINT uq_prt_token UNIQUE (token),
    CONSTRAINT fk_prt_user  FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 11. remember_me_token
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS remember_me_token (
    token      VARCHAR(64) NOT NULL,
    user_id    BIGINT      NOT NULL,
    expires_at DATETIME    NOT NULL,
    CONSTRAINT pk_rmt      PRIMARY KEY (token),
    CONSTRAINT fk_rmt_user FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- 12. driver_schedule  (weekly recurring driver assignments)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS driver_schedule (
    ds_id          BIGINT      NOT NULL AUTO_INCREMENT,
    driver_id      BIGINT      NOT NULL,
    bus_id         BIGINT      NOT NULL,
    route_id       BIGINT      NOT NULL,
    shift_type     VARCHAR(20) NOT NULL,
    shift_start    TIME        NOT NULL,
    shift_end      TIME        NOT NULL,
    week_start_date DATE       NOT NULL,
    published      TINYINT(1)  NOT NULL DEFAULT 0,
    CONSTRAINT pk_driver_schedule       PRIMARY KEY (ds_id),
    CONSTRAINT fk_ds_driver FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    CONSTRAINT fk_ds_bus    FOREIGN KEY (bus_id)    REFERENCES bus(bus_id),
    CONSTRAINT fk_ds_route  FOREIGN KEY (route_id)  REFERENCES route(route_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS bus_stop (
    stop_id   BIGINT       NOT NULL AUTO_INCREMENT,
    stop_name VARCHAR(150) NOT NULL,
    latitude  DOUBLE,
    longitude DOUBLE,
    CONSTRAINT pk_bus_stop PRIMARY KEY (stop_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS stop_route (
    stop_id  BIGINT NOT NULL,
    route_id BIGINT NOT NULL,
    CONSTRAINT pk_stop_route PRIMARY KEY (stop_id, route_id),
    CONSTRAINT fk_sr_stop  FOREIGN KEY (stop_id)  REFERENCES bus_stop(stop_id) ON DELETE CASCADE,
    CONSTRAINT fk_sr_route FOREIGN KEY (route_id) REFERENCES route(route_id)  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- SEED DATA
-- ============================================================
-- Single admin account (password: M@sydo123 — auto-migrated to BCrypt on first login)
INSERT IGNORE INTO user (name, email, password, role, status) VALUES
    ('Administrator', 'Maetsok01@gmail.com', 'M@sydo123', 'ADMIN', 'ACTIVE');

