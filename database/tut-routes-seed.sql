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

INSERT INTO routes (route_name, start_location, end_location, start_lat, start_lng, end_lat, end_lng) VALUES
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
