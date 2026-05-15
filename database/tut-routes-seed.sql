-- ============================================================
--  TUT Campus Routes – SmartBus Seed Data
--  Run this once against your Railway MySQL database to
--  populate all 14 standard TUT bus routes.
--
--  Campus coordinates reference:
--    Soshanguve North : -25.5275, 28.0952
--    Soshanguve South : -25.5358, 28.1065
--    Pretoria Campus  : -25.7313, 28.1648
--    Arcadia Campus   : -25.7469, 28.1961
--    Ga-Rankuwa Campus: -25.6169, 27.9964
-- ============================================================

INSERT INTO route (route_name, start_location, end_location, start_lat, start_lng, end_lat, end_lng) VALUES
-- ── Morning Routes ─────────────────────────────────────────
('Route 1 – Soshanguve North → Pretoria',
 'Soshanguve North Campus', 'Pretoria Campus',
 -25.5275, 28.0952, -25.7313, 28.1648),

('Route 2 – Soshanguve South → Pretoria',
 'Soshanguve South Campus', 'Pretoria Campus',
 -25.5358, 28.1065, -25.7313, 28.1648),

('Route 3 – Soshanguve North → Arcadia',
 'Soshanguve North Campus', 'Arcadia Campus',
 -25.5275, 28.0952, -25.7469, 28.1961),

('Route 4 – Ga-Rankuwa → Pretoria',
 'Ga-Rankuwa Campus', 'Pretoria Campus',
 -25.6169, 27.9964, -25.7313, 28.1648),

('Route 5 – Ga-Rankuwa → Arcadia',
 'Ga-Rankuwa Campus', 'Arcadia Campus',
 -25.6169, 27.9964, -25.7469, 28.1961),

-- ── Shuttle Routes ─────────────────────────────────────────
('Route 6 – Arcadia ↔ Pretoria Shuttle A',
 'Arcadia Campus', 'Pretoria Campus',
 -25.7469, 28.1961, -25.7313, 28.1648),

('Route 7 – Pretoria ↔ Arcadia Shuttle B',
 'Pretoria Campus', 'Arcadia Campus',
 -25.7313, 28.1648, -25.7469, 28.1961),

('Route 8 – Arcadia ↔ Pretoria Shuttle C',
 'Arcadia Campus', 'Pretoria Campus',
 -25.7469, 28.1961, -25.7313, 28.1648),

('Route 9 – Pretoria ↔ Arcadia Shuttle D',
 'Pretoria Campus', 'Arcadia Campus',
 -25.7313, 28.1648, -25.7469, 28.1961),

-- ── Afternoon Routes ───────────────────────────────────────
('Route 10 – Pretoria → Soshanguve North',
 'Pretoria Campus', 'Soshanguve North Campus',
 -25.7313, 28.1648, -25.5275, 28.0952),

('Route 11 – Pretoria → Soshanguve South',
 'Pretoria Campus', 'Soshanguve South Campus',
 -25.7313, 28.1648, -25.5358, 28.1065),

('Route 12 – Arcadia → Soshanguve North',
 'Arcadia Campus', 'Soshanguve North Campus',
 -25.7469, 28.1961, -25.5275, 28.0952),

('Route 13 – Pretoria → Ga-Rankuwa',
 'Pretoria Campus', 'Ga-Rankuwa Campus',
 -25.7313, 28.1648, -25.6169, 27.9964),

('Route 14 – Arcadia → Ga-Rankuwa',
 'Arcadia Campus', 'Ga-Rankuwa Campus',
 -25.7469, 28.1961, -25.6169, 27.9964);

-- ============================================================
-- BUS STOPS — one terminal per campus + mid-route stops
-- Use INSERT IGNORE so re-running is safe.
-- ============================================================
INSERT IGNORE INTO bus_stop (stop_name, latitude, longitude) VALUES
('Soshanguve North Campus Terminal',  -25.5275, 28.0952),
('Soshanguve South Campus Terminal',  -25.5358, 28.1065),
('Pretoria Campus Terminal',          -25.7313, 28.1648),
('Arcadia Campus Terminal',           -25.7469, 28.1961),
('Ga-Rankuwa Campus Terminal',        -25.6169, 27.9964),
-- Mid-route stops along Route 1 / Route 10 (Soshanguve ↔ Pretoria corridor)
('Mabopane Station',                  -25.5761, 28.1047),
('Rosslyn Industrial',                -25.6311, 28.0914),
('Pretoria North Mall',               -25.6620, 28.1189),
-- Mid-route stop along Route 4 / Route 13 (Ga-Rankuwa ↔ Pretoria corridor)
('Pretoria West – Hercules',          -25.7192, 28.1297);

-- ============================================================
-- STOP ↔ ROUTE ASSOCIATIONS  (uses subselects — safe to re-run)
-- ============================================================

-- Soshanguve North Terminal → Routes 1, 3, 10, 12
INSERT IGNORE INTO stop_route (stop_id, route_id)
SELECT s.stop_id, r.route_id FROM bus_stop s
  JOIN route r ON r.route_name IN (
      'Route 1 – Soshanguve North → Pretoria',
      'Route 3 – Soshanguve North → Arcadia',
      'Route 10 – Pretoria → Soshanguve North',
      'Route 12 – Arcadia → Soshanguve North')
WHERE s.stop_name = 'Soshanguve North Campus Terminal';

-- Soshanguve South Terminal → Routes 2, 11
INSERT IGNORE INTO stop_route (stop_id, route_id)
SELECT s.stop_id, r.route_id FROM bus_stop s
  JOIN route r ON r.route_name IN (
      'Route 2 – Soshanguve South → Pretoria',
      'Route 11 – Pretoria → Soshanguve South')
WHERE s.stop_name = 'Soshanguve South Campus Terminal';

-- Pretoria Campus Terminal → Routes 1, 2, 4, 6, 7, 8, 9, 10, 11, 13
INSERT IGNORE INTO stop_route (stop_id, route_id)
SELECT s.stop_id, r.route_id FROM bus_stop s
  JOIN route r ON r.route_name IN (
      'Route 1 – Soshanguve North → Pretoria',
      'Route 2 – Soshanguve South → Pretoria',
      'Route 4 – Ga-Rankuwa → Pretoria',
      'Route 6 – Arcadia ↔ Pretoria Shuttle A',
      'Route 7 – Pretoria ↔ Arcadia Shuttle B',
      'Route 8 – Arcadia ↔ Pretoria Shuttle C',
      'Route 9 – Pretoria ↔ Arcadia Shuttle D',
      'Route 10 – Pretoria → Soshanguve North',
      'Route 11 – Pretoria → Soshanguve South',
      'Route 13 – Pretoria → Ga-Rankuwa')
WHERE s.stop_name = 'Pretoria Campus Terminal';

-- Arcadia Campus Terminal → Routes 3, 5, 6, 7, 8, 9, 12, 14
INSERT IGNORE INTO stop_route (stop_id, route_id)
SELECT s.stop_id, r.route_id FROM bus_stop s
  JOIN route r ON r.route_name IN (
      'Route 3 – Soshanguve North → Arcadia',
      'Route 5 – Ga-Rankuwa → Arcadia',
      'Route 6 – Arcadia ↔ Pretoria Shuttle A',
      'Route 7 – Pretoria ↔ Arcadia Shuttle B',
      'Route 8 – Arcadia ↔ Pretoria Shuttle C',
      'Route 9 – Pretoria ↔ Arcadia Shuttle D',
      'Route 12 – Arcadia → Soshanguve North',
      'Route 14 – Arcadia → Ga-Rankuwa')
WHERE s.stop_name = 'Arcadia Campus Terminal';

-- Ga-Rankuwa Campus Terminal → Routes 4, 5, 13, 14
INSERT IGNORE INTO stop_route (stop_id, route_id)
SELECT s.stop_id, r.route_id FROM bus_stop s
  JOIN route r ON r.route_name IN (
      'Route 4 – Ga-Rankuwa → Pretoria',
      'Route 5 – Ga-Rankuwa → Arcadia',
      'Route 13 – Pretoria → Ga-Rankuwa',
      'Route 14 – Arcadia → Ga-Rankuwa')
WHERE s.stop_name = 'Ga-Rankuwa Campus Terminal';

-- Mid-stop: Mabopane Station → Routes 1, 2, 10, 11
INSERT IGNORE INTO stop_route (stop_id, route_id)
SELECT s.stop_id, r.route_id FROM bus_stop s
  JOIN route r ON r.route_name IN (
      'Route 1 – Soshanguve North → Pretoria',
      'Route 2 – Soshanguve South → Pretoria',
      'Route 10 – Pretoria → Soshanguve North',
      'Route 11 – Pretoria → Soshanguve South')
WHERE s.stop_name = 'Mabopane Station';

-- Mid-stop: Rosslyn Industrial → Routes 1, 10
INSERT IGNORE INTO stop_route (stop_id, route_id)
SELECT s.stop_id, r.route_id FROM bus_stop s
  JOIN route r ON r.route_name IN (
      'Route 1 – Soshanguve North → Pretoria',
      'Route 10 – Pretoria → Soshanguve North')
WHERE s.stop_name = 'Rosslyn Industrial';

-- Mid-stop: Pretoria North Mall → Routes 1, 2, 10, 11
INSERT IGNORE INTO stop_route (stop_id, route_id)
SELECT s.stop_id, r.route_id FROM bus_stop s
  JOIN route r ON r.route_name IN (
      'Route 1 – Soshanguve North → Pretoria',
      'Route 2 – Soshanguve South → Pretoria',
      'Route 10 – Pretoria → Soshanguve North',
      'Route 11 – Pretoria → Soshanguve South')
WHERE s.stop_name = 'Pretoria North Mall';

-- Mid-stop: Pretoria West – Hercules → Routes 4, 13
INSERT IGNORE INTO stop_route (stop_id, route_id)
SELECT s.stop_id, r.route_id FROM bus_stop s
  JOIN route r ON r.route_name IN (
      'Route 4 – Ga-Rankuwa → Pretoria',
      'Route 13 – Pretoria → Ga-Rankuwa')
WHERE s.stop_name = 'Pretoria West – Hercules';
