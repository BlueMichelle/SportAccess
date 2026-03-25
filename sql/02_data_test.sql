-- ============================================================
--  SportAccess – Datos de Prueba (seed)
--  Tarea T-04 · M5: DB / QA / DevOps
--  Actualizado: 25-03-2026 (alineado con código de M1)
-- ============================================================

USE sportaccess;

-- ----------------------------------------------------------------
-- Usuarios de prueba
-- ----------------------------------------------------------------
INSERT INTO users (firebase_uid, name, email, telefono, role, activo) VALUES
('firebase-uid-admin-001',    'Admin SportAccess',  'admin@sportaccess.com',   '600000001', 'ADMIN',  1),
('firebase-uid-cliente-001',  'Carlos López',       'carlos@ejemplo.com',      '611111111', 'CLIENT', 1),
('firebase-uid-cliente-002',  'María García',       'maria@ejemplo.com',       '622222222', 'CLIENT', 1),
('firebase-uid-cliente-003',  'Juan Martínez',      'juan@ejemplo.com',        '633333333', 'CLIENT', 1),
('firebase-uid-cliente-004',  'Ana Fernández',      'ana@ejemplo.com',         '644444444', 'CLIENT', 1);


-- ----------------------------------------------------------------
-- Centros deportivos
-- ----------------------------------------------------------------
INSERT INTO sports_centers (name, address, latitude, longitude, contact_phone) VALUES
('Polideportivo Central',  'Calle Mayor 10, Madrid',        40.4168, -3.7038, '910000001'),
('Club Deportivo Norte',   'Av. de la Libertad 25, Madrid', 40.4500, -3.6890, '910000002');


-- ----------------------------------------------------------------
-- Pistas deportivas
-- ----------------------------------------------------------------
INSERT INTO courts (name, type, price_per_hour, center_id) VALUES
('Pista Pádel 1',       'PADEL',       12.00, 1),
('Pista Pádel 2',       'PADEL',       12.00, 1),
('Pista Tenis A',       'TENNIS',      15.00, 1),
('Pista Tenis B',       'TENNIS',      15.00, 2),
('Fútbol Sala 1',       'FOOTBALL',    20.00, 2),
('Pista Baloncesto',    'BASKETBALL',  18.00, 2);


-- ----------------------------------------------------------------
-- Reservas de prueba
-- ----------------------------------------------------------------
INSERT INTO bookings (user_id, court_id, start_time, end_time, status, qr_code, version) VALUES
(2, 1, '2026-03-26 10:00:00', '2026-03-26 11:00:00', 'CONFIRMED',  UUID(), 0),
(3, 3, '2026-03-26 12:00:00', '2026-03-26 13:30:00', 'PENDING',    UUID(), 0),
(4, 5, '2026-03-26 18:00:00', '2026-03-26 19:00:00', 'CONFIRMED',  UUID(), 0),
(5, 6, '2026-03-27 09:00:00', '2026-03-27 10:00:00', 'CANCELLED',  UUID(), 0),
(2, 2, '2026-03-27 11:00:00', '2026-03-27 12:00:00', 'COMPLETED',  UUID(), 0);


-- ----------------------------------------------------------------
-- Pagos de prueba
-- ----------------------------------------------------------------
INSERT INTO payments (booking_id, stripe_payment_intent_id, amount, payment_date, status) VALUES
(1, 'pi_test_001_padel',  12.00, '2026-03-25 09:30:00', 'SUCCEEDED'),
(3, 'pi_test_002_futbol', 20.00, '2026-03-25 17:00:00', 'SUCCEEDED'),
(4, NULL,                 18.00, NULL,                   'FAILED'),
(5, 'pi_test_003_padel',  12.00, '2026-03-26 10:30:00', 'REFUNDED');


-- ----------------------------------------------------------------
-- Incidencias de prueba
-- ----------------------------------------------------------------
INSERT INTO incidents (user_id, court_id, description, status, reported_at) VALUES
(2, 1, 'La red de la pista pádel 1 está rota por la parte central.',          'OPEN',         '2026-03-24 14:00:00'),
(4, 5, 'El marcador electrónico de la sala no funciona correctamente.',        'IN_PROGRESS',  '2026-03-24 16:30:00'),
(1, 3, 'Bache en la pista de tenis A, zona de servicio derecha.',              'RESOLVED',     '2026-03-23 11:00:00');
