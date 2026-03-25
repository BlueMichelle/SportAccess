-- ============================================================
--  SportAccess – Consultas útiles / de verificación
--  Tarea T-04 · M5: DB / QA / DevOps
-- ============================================================

USE sportaccess_db;

-- ── Ver todas las pistas activas ──────────────────────────────
SELECT id, nombre, tipo, precio_por_hora
FROM courts
WHERE activa = 1
ORDER BY tipo, nombre;


-- ── Ver reservas con datos del usuario y pista ───────────────
SELECT
    r.id            AS reserva_id,
    u.nombre        AS usuario,
    c.nombre        AS pista,
    c.tipo          AS tipo_pista,
    r.fecha_inicio,
    r.fecha_fin,
    r.estado,
    r.qr_token
FROM reservations r
JOIN users  u ON r.user_id  = u.id
JOIN courts c ON r.court_id = c.id
ORDER BY r.fecha_inicio DESC;


-- ── Disponibilidad de pista en un rango horario ──────────────
-- (cambia los valores de fecha y court_id según necesites)
SELECT r.id, u.nombre AS usuario, r.fecha_inicio, r.fecha_fin, r.estado
FROM reservations r
JOIN users u ON r.user_id = u.id
WHERE r.court_id = 1
  AND r.estado NOT IN ('CANCELADA', 'COMPLETADA')
  AND r.fecha_inicio < '2026-03-22 12:00:00'
  AND r.fecha_fin    > '2026-03-22 10:00:00';


-- ── Incidencias abiertas por pista ───────────────────────────
SELECT
    i.id,
    c.nombre    AS pista,
    u.nombre    AS reportado_por,
    i.descripcion,
    i.estado,
    i.fecha_reporte
FROM incidents i
JOIN courts c ON i.court_id    = c.id
JOIN users  u ON i.reported_by = u.id
WHERE i.estado != 'RESUELTA'
ORDER BY i.fecha_reporte ASC;


-- ── Ingresos por pista (reservas confirmadas/completadas) ────
SELECT
    c.nombre        AS pista,
    c.tipo,
    COUNT(r.id)                                           AS total_reservas,
    SUM(TIMESTAMPDIFF(HOUR, r.fecha_inicio, r.fecha_fin)
        * c.precio_por_hora)                             AS ingresos_totales_eur
FROM reservations r
JOIN courts c ON r.court_id = c.id
WHERE r.estado IN ('CONFIRMADA', 'ACTIVA', 'COMPLETADA')
GROUP BY c.id, c.nombre, c.tipo
ORDER BY ingresos_totales_eur DESC;


-- ── Reservas del último mes por usuario ──────────────────────
SELECT
    u.nombre,
    u.email,
    COUNT(r.id) AS reservas_mes
FROM reservations r
JOIN users u ON r.user_id = u.id
WHERE r.fecha_creacion >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY u.id, u.nombre, u.email
ORDER BY reservas_mes DESC;
