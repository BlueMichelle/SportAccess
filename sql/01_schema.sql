-- ============================================================
--  SportAccess – Esquema de Base de Datos MySQL
--  Tarea T-04 · M5: DB / QA / DevOps
--  Actualizado: 25-03-2026 (alineado con código de M1)
--  Versión:  2.0
-- ============================================================

-- Crear y seleccionar la base de datos
CREATE DATABASE IF NOT EXISTS sportaccess
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sportaccess;

-- ============================================================
-- TABLA: users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    firebase_uid    VARCHAR(128)    NOT NULL,
    name            VARCHAR(100)    NOT NULL,
    email           VARCHAR(150)    NOT NULL,
    telefono        VARCHAR(20),
    role            ENUM('CLIENT', 'ADMIN') NOT NULL DEFAULT 'CLIENT',
    activo          TINYINT(1)      NOT NULL DEFAULT 1,
    fecha_registro  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_users_firebase_uid (firebase_uid),
    UNIQUE KEY uq_users_email        (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLA: sports_centers  (centros deportivos)
-- ============================================================
CREATE TABLE IF NOT EXISTS sports_centers (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    name            VARCHAR(100)    NOT NULL,
    address         VARCHAR(255),
    latitude        DOUBLE,
    longitude       DOUBLE,
    contact_phone   VARCHAR(20),

    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLA: courts  (pistas deportivas)
-- ============================================================
CREATE TABLE IF NOT EXISTS courts (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    name            VARCHAR(100)    NOT NULL,
    type            ENUM('PADEL', 'TENNIS', 'FOOTBALL', 'BASKETBALL') NOT NULL,
    price_per_hour  DOUBLE          NOT NULL,
    center_id       BIGINT          NOT NULL,

    PRIMARY KEY (id),
    CONSTRAINT fk_courts_center
        FOREIGN KEY (center_id) REFERENCES sports_centers (id) ON DELETE RESTRICT ON UPDATE CASCADE,

    INDEX idx_courts_center_id (center_id),
    INDEX idx_courts_type      (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLA: bookings  (reservas)
-- ============================================================
CREATE TABLE IF NOT EXISTS bookings (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    user_id         BIGINT          NOT NULL,
    court_id        BIGINT          NOT NULL,
    start_time      DATETIME        NOT NULL,
    end_time        DATETIME        NOT NULL,
    status          ENUM(
                        'PENDING',       -- Reserva creada, pago pendiente
                        'CONFIRMED',     -- Pago confirmado, QR activo
                        'COMPLETED',     -- Sesión finalizada
                        'CANCELLED'      -- Reserva cancelada
                    ) NOT NULL DEFAULT 'PENDING',
    qr_code         VARCHAR(255),
    version         BIGINT          DEFAULT 0,     -- Optimistic locking

    PRIMARY KEY (id),
    CONSTRAINT fk_bookings_user
        FOREIGN KEY (user_id)  REFERENCES users  (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_bookings_court
        FOREIGN KEY (court_id) REFERENCES courts (id) ON DELETE RESTRICT ON UPDATE CASCADE,

    INDEX idx_bookings_user_id    (user_id),
    INDEX idx_bookings_court_id   (court_id),
    INDEX idx_bookings_status     (status),
    INDEX idx_bookings_time       (start_time, end_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLA: payments  (pagos con Stripe)
-- ============================================================
CREATE TABLE IF NOT EXISTS payments (
    id                      BIGINT        NOT NULL AUTO_INCREMENT,
    booking_id              BIGINT        NOT NULL,
    stripe_payment_intent_id VARCHAR(255),
    amount                  DOUBLE,
    payment_date            DATETIME,
    status                  ENUM('PENDING', 'SUCCEEDED', 'FAILED', 'REFUNDED')
                            NOT NULL DEFAULT 'PENDING',

    PRIMARY KEY (id),
    CONSTRAINT fk_payments_booking
        FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE RESTRICT ON UPDATE CASCADE,

    UNIQUE KEY uq_payments_booking (booking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLA: incidents  (incidencias)
-- ============================================================
CREATE TABLE IF NOT EXISTS incidents (
    id              BIGINT        NOT NULL AUTO_INCREMENT,
    user_id         BIGINT        NOT NULL,
    court_id        BIGINT,
    description     VARCHAR(500)  NOT NULL,
    image_url       VARCHAR(512),             -- URL Firebase Storage
    reported_at     DATETIME,
    status          ENUM('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')
                    NOT NULL DEFAULT 'OPEN',

    PRIMARY KEY (id),
    CONSTRAINT fk_incidents_user
        FOREIGN KEY (user_id)  REFERENCES users  (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_incidents_court
        FOREIGN KEY (court_id) REFERENCES courts (id) ON DELETE SET NULL ON UPDATE CASCADE,

    INDEX idx_incidents_court_id  (court_id),
    INDEX idx_incidents_status    (status),
    INDEX idx_incidents_user_id   (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
