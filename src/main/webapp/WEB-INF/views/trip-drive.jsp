<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<title>SmartBus – Drive</title>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css"/>
<style>
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:"Segoe UI",sans-serif; height:100vh; overflow:hidden; background:#0a0f1e; color:#e2e8f0; }
  #map { position:fixed; inset:0; z-index:0; }
  #topbar {
    position:fixed; top:0; left:0; right:0; z-index:500;
    display:flex; align-items:center; gap:10px; padding:10px 14px;
    background:linear-gradient(180deg,rgba(10,15,30,0.95) 0%,rgba(10,15,30,0) 100%);
    pointer-events:none;
  }
  #topbar > * { pointer-events:all; }
  .back-btn {
    width:38px;height:38px;border-radius:50%;border:none;
    background:rgba(255,255,255,0.1);color:#fff;font-size:1rem;
    display:flex;align-items:center;justify-content:center;cursor:pointer;
  }
  .back-btn:hover { background:rgba(255,255,255,0.2); }
  .route-pill {
    background:rgba(255,255,255,0.12);color:#fff;border-radius:20px;
    padding:5px 13px;font-size:0.82rem;font-weight:700;border:1px solid rgba(255,255,255,0.15);
  }
  #status-chip {
    margin-left:auto;border-radius:20px;padding:4px 12px;font-size:0.76rem;
    font-weight:700;display:flex;align-items:center;gap:5px;
    background:rgba(34,197,94,0.2);color:#4ade80;border:1px solid rgba(34,197,94,0.3);
  }
  .live-dot { width:7px;height:7px;border-radius:50%;background:#22c55e;animation:blink 1.2s infinite; }
  @keyframes blink { 0%,100%{opacity:1} 50%{opacity:0.3} }
  #instruction-bar {
    position:fixed; top:60px; left:14px; right:14px; z-index:450;
    background:rgba(15,23,42,0.92); border:1px solid #334155;
    border-radius:14px; padding:12px 16px;
    display:flex; align-items:center; gap:12px;
  }
  .turn-icon { font-size:1.6rem; color:#22c55e; flex-shrink:0; }
  #instruction-text { font-size:0.9rem; font-weight:600; color:#e2e8f0; flex:1; }
  #distance-text { font-size:0.78rem; color:#94a3b8; margin-top:2px; }
  #map-controls {
    position:fixed; right:14px; top:50%; transform:translateY(-50%);
    z-index:400; display:flex; flex-direction:column; gap:8px;
  }
  .map-btn {
    width:42px;height:42px;border-radius:12px;border:none;
    background:rgba(15,23,42,0.85);color:#e2e8f0;font-size:1.2rem;
    display:flex;align-items:center;justify-content:center;cursor:pointer;
    border:1px solid #334155;
  }
  .map-btn:hover { background:#1e293b; }
  #bottom-sheet {
    position:fixed; bottom:0; left:0; right:0; z-index:500;
    background:#0f172a; border-radius:22px 22px 0 0;
    border-top:1px solid #334155;
    max-height:55vh; overflow:hidden; display:flex; flex-direction:column;
    transition:max-height 0.3s ease;
  }
  #sheet-handle { flex-shrink:0; padding:10px 0 4px; display:flex; justify-content:center; cursor:pointer; }
  .handle-bar { width:40px; height:4px; border-radius:2px; background:#334155; }
  #sheet-inner { overflow-y:auto; flex:1; padding:0 16px 24px; }
  .sheet-title { font-size:0.72rem; font-weight:700; color:#475569; text-transform:uppercase; letter-spacing:0.07em; margin-bottom:10px; }
  #action-row { display:flex; gap:10px; margin-bottom:14px; }
  .action-btn {
    flex:1; padding:11px 8px; border-radius:12px; border:none; cursor:pointer;
    font-size:0.82rem; font-weight:700; display:flex; align-items:center; justify-content:center; gap:6px;
  }
  .btn-start  { background:#16a34a; color:#fff; }
  .btn-arrive { background:#2563eb; color:#fff; }
  .btn-delay  { background:#1e293b; color:#94a3b8; border:1px solid #334155; }
  .btn-end    { background:#dc2626; color:#fff; }
  .action-btn:hover { opacity:0.88; }
  #next-stop-card {
    background:#1e293b; border-radius:12px; padding:12px 14px;
    border:1px solid #334155; margin-bottom:14px;
    display:flex; align-items:center; gap:12px;
  }
  .next-stop-icon { width:36px; height:36px; border-radius:50%; background:#22c55e; color:#fff; font-size:0.9rem; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
  #next-stop-name { font-weight:700; font-size:0.9rem; color:#e2e8f0; }
  #next-stop-dist { font-size:0.75rem; color:#64748b; margin-top:2px; }
  .timeline-item { display:flex; align-items:center; gap:10px; padding:7px 0; }
  .t-dot { width:10px; height:10px; border-radius:50%; background:#334155; flex-shrink:0; }
  .t-dot.done { background:#22c55e; }
  .t-dot.active { background:#22c55e; box-shadow:0 0 0 4px rgba(34,197,94,0.2); }
  .t-name { font-size:0.85rem; color:#94a3b8; }
  .t-name.active { color:#e2e8f0; font-weight:600; }
  /* delay modal */
  #delay-modal { display:none; position:fixed; inset:0; z-index:600; background:rgba(0,0,0,0.7); align-items:center; justify-content:center; }
  #delay-modal.open { display:flex; }
  .modal-box { background:#0f172a; border-radius:16px; border:1px solid #334155; padding:24px; width:88%; max-width:380px; }
  .modal-title { font-size:1rem; font-weight:700; margin-bottom:14px; }
  .modal-box textarea { width:100%; background:#1e293b; color:#e2e8f0; border:1px solid #334155; border-radius:8px; padding:10px; font-size:0.85rem; resize:none; }
  .modal-btns { display:flex; gap:10px; margin-top:14px; }
  .modal-btns button { flex:1; padding:10px; border-radius:8px; border:none; cursor:pointer; font-weight:700; }
  .modal-cancel { background:#1e293b; color:#94a3b8; }
  .modal-send   { background:#d97706; color:#fff; }
  /* AI Risk Banner */
  #ai-risk-banner {
    display:none; position:fixed; top:130px; left:14px; right:14px; z-index:449;
    border-radius:12px; padding:11px 14px;
    align-items:center; gap:10px; font-size:0.82rem;
    backdrop-filter:blur(4px);
  }
  #ai-risk-banner.visible { display:flex; }
  #ai-risk-banner.risk-HIGH  { background:rgba(220,38,38,0.18); border:1px solid rgba(220,38,38,0.4); color:#fca5a5; }
  #ai-risk-banner.risk-MEDIUM{ background:rgba(245,158,11,0.18); border:1px solid rgba(245,158,11,0.4); color:#fcd34d; }
</style>
</head>
<body>
<div id="map"></div>

<div id="topbar">
  <button class="back-btn" onclick="history.back()"><i class="bi bi-arrow-left"></i></button>
  <div class="route-pill"><i class="bi bi-bus-front-fill" style="color:#22c55e"></i> ${trip.route.routeName}</div>
  <div id="status-chip"><div class="live-dot"></div><span id="gps-label">GPS Off</span></div>
</div>

<div id="instruction-bar">
  <div class="turn-icon" id="turn-icon"><i class="bi bi-arrow-up-circle-fill"></i></div>
  <div>
    <div id="instruction-text">Starting navigation…</div>
    <div id="distance-text">—</div>
  </div>
</div>

<!-- AI Delay Risk Banner -->
<div id="ai-risk-banner">
  <span id="ai-risk-icon" style="font-size:1.2rem;flex-shrink:0">🤖</span>
  <div style="flex:1">
    <div id="ai-risk-msg" style="font-weight:700">Analysing route…</div>
    <div id="ai-risk-conf" style="font-size:0.72rem;opacity:0.8;margin-top:2px">AI delay prediction</div>
  </div>
  <button onclick="document.getElementById('ai-risk-banner').classList.remove('visible')" style="background:none;border:none;cursor:pointer;color:inherit;font-size:1rem;flex-shrink:0">✕</button>
</div>

<div id="map-controls">
  <button class="map-btn" id="zoom-in"  onclick="map.zoomIn()"><i class="bi bi-plus"></i></button>
  <button class="map-btn" id="zoom-out" onclick="map.zoomOut()"><i class="bi bi-dash"></i></button>
  <button class="map-btn" onclick="recenterMap()"><i class="bi bi-crosshair2"></i></button>
</div>

<div id="bottom-sheet">
  <div id="sheet-handle" onclick="toggleSheet()"><div class="handle-bar"></div></div>
  <div id="sheet-inner">
    <div id="action-row">
      <c:choose>
        <c:when test="${trip.status == 'SCHEDULED'}">
          <button class="action-btn btn-start" onclick="updateStatus('IN_PROGRESS')"><i class="bi bi-play-fill"></i>Start Trip</button>
        </c:when>
        <c:when test="${trip.status == 'IN_PROGRESS'}">
          <button class="action-btn btn-arrive" onclick="updateStatus('COMPLETED')"><i class="bi bi-flag-fill"></i>Complete</button>
          <button class="action-btn btn-delay" onclick="openDelay()"><i class="bi bi-clock-history"></i>Delay</button>
        </c:when>
        <c:otherwise>
          <button class="action-btn btn-delay" disabled style="opacity:.4"><i class="bi bi-check-circle-fill"></i>${trip.status}</button>
        </c:otherwise>
      </c:choose>
    </div>
    <div id="next-stop-card">
      <div class="next-stop-icon"><i class="bi bi-geo-alt-fill"></i></div>
      <div>
        <div id="next-stop-name">${trip.route.endLocation}</div>
        <div id="next-stop-dist">Destination</div>
      </div>
    </div>
    <div class="sheet-title">Route</div>
    <div id="route-timeline">
      <div class="timeline-item"><div class="t-dot done"></div><div class="t-name">${trip.route.startLocation}</div></div>
      <div class="timeline-item"><div class="t-dot active"></div><div class="t-name active">${trip.route.endLocation}</div></div>
    </div>
  </div>
</div>

<div id="delay-modal">
  <div class="modal-box">
    <div class="modal-title"><i class="bi bi-clock-history" style="color:#f59e0b"></i> Report Delay</div>
    <textarea id="delay-msg" rows="3" placeholder="Reason for delay…"></textarea>
    <div class="modal-btns">
      <button class="modal-cancel" onclick="closeDelay()">Cancel</button>
      <button class="modal-send" onclick="sendDelay()">Send</button>
    </div>
  </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
const TRIP_ID = ${trip.tripId};
const CTX     = '${pageContext.request.contextPath}';
const DARK_TILES = 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

// Route endpoint coordinates (from DB — null-safe via JSP EL)
const ROUTE_START_LAT = '${trip.route.startLat}' !== '' ? parseFloat('${trip.route.startLat}') : null;
const ROUTE_START_LNG = '${trip.route.startLng}' !== '' ? parseFloat('${trip.route.startLng}') : null;
const ROUTE_END_LAT   = '${trip.route.endLat}'   !== '' ? parseFloat('${trip.route.endLat}')   : null;
const ROUTE_END_LNG   = '${trip.route.endLng}'   !== '' ? parseFloat('${trip.route.endLng}')   : null;

let map, driverMarker, routeLayer, historyLayer;
let lastLat = null, lastLng = null;
let watchId = null, tracking = false;
let steps = [], stepIdx = 0, sheetExpanded = true;

function initMap() {
  map = L.map('map', { zoomControl:false, attributionControl:false });
  L.tileLayer(DARK_TILES, { maxZoom:19 }).addTo(map);
  // Default centre on Pretoria / TUT area; overridden once GPS or route loads
  const defaultCenter = (ROUTE_START_LAT && ROUTE_START_LNG)
    ? [ROUTE_START_LAT, ROUTE_START_LNG]
    : [-25.7313, 28.1648]; // Pretoria Campus fallback
  map.setView(defaultCenter, 13);

  // Show origin + destination markers if coordinates are available
  if (ROUTE_START_LAT && ROUTE_START_LNG) {
    L.circleMarker([ROUTE_START_LAT, ROUTE_START_LNG], {radius:7, color:'#22c55e', fillColor:'#22c55e', fillOpacity:0.8})
      .addTo(map).bindPopup('${trip.route.startLocation}');
  }
  if (ROUTE_END_LAT && ROUTE_END_LNG) {
    L.circleMarker([ROUTE_END_LAT, ROUTE_END_LNG], {radius:7, color:'#ef4444', fillColor:'#ef4444', fillOpacity:0.8})
      .addTo(map).bindPopup('${trip.route.endLocation}');
  }
  if (ROUTE_START_LAT && ROUTE_END_LAT) {
    // Draw straight-line preview until OSRM loads
    routeLayer = L.polyline([[ROUTE_START_LAT, ROUTE_START_LNG],[ROUTE_END_LAT, ROUTE_END_LNG]],
      {color:'#3b82f6', weight:3, dashArray:'8 6', opacity:0.5}).addTo(map);
    map.fitBounds(routeLayer.getBounds(), {padding:[60,60]});
  }
  loadRouteHistory();
}

function busIcon() {
  return L.divIcon({
    className:'',
    html:'<div style="width:36px;height:36px;border-radius:50%;background:#22c55e;border:3px solid #fff;display:flex;align-items:center;justify-content:center;color:#fff;font-size:1.1rem;box-shadow:0 0 12px rgba(34,197,94,0.6)"><i class=\'bi bi-bus-front-fill\'></i></div>',
    iconSize:[36,36], iconAnchor:[18,18]
  });
}

function loadRouteHistory() {
  fetch(CTX+'/tracking/history?tripId='+TRIP_ID)
    .then(r=>r.json())
    .then(pts=>{
      if (pts.length) {
        if (historyLayer) map.removeLayer(historyLayer);
        historyLayer = L.polyline(pts, {color:'#22c55e',weight:3,opacity:0.5,dashArray:'6 6'}).addTo(map);
        if (!lastLat) map.fitBounds(historyLayer.getBounds(), {padding:[60,60]});
      }
      if (!lastLat) startTracking();
      else startTracking();
    }).catch(()=>startTracking());
}

function startTracking() {
  if (!navigator.geolocation) return;
  watchId = navigator.geolocation.watchPosition(onPos, ()=>{}, { enableHighAccuracy:true, maximumAge:3000 });
  tracking = true;
}

function onPos(pos) {
  lastLat = pos.coords.latitude;
  lastLng = pos.coords.longitude;
  document.getElementById('gps-label').textContent = 'Live';
  if (!driverMarker) {
    driverMarker = L.marker([lastLat,lastLng], {icon:busIcon()}).addTo(map);
    map.setView([lastLat,lastLng], 15);
    buildOsrmRoute(lastLat, lastLng); // build real road route from driver position to destination
  } else {
    driverMarker.setLatLng([lastLat,lastLng]);
    advanceStep(lastLat, lastLng);
  }
  sendGps(lastLat, lastLng);
}

function buildOsrmRoute(lat, lng) {
  if (!ROUTE_END_LAT || !ROUTE_END_LNG) return;
  const url = 'https://router.project-osrm.org/route/v1/driving/'
    + lng + ',' + lat + ';'
    + ROUTE_END_LNG + ',' + ROUTE_END_LAT
    + '?steps=true&overview=full&geometries=geojson';
  fetch(url)
    .then(r => r.json())
    .then(data => {
      if (!data.routes || !data.routes.length) return;
      const route = data.routes[0];
      // Replace preview line with real road geometry
      if (routeLayer) map.removeLayer(routeLayer);
      const coords = route.geometry.coordinates.map(c => [c[1], c[0]]);
      routeLayer = L.polyline(coords, {color:'#22c55e', weight:4, opacity:0.85}).addTo(map);
      // Build turn-by-turn steps
      steps = [];
      (route.legs || []).forEach(leg => {
        (leg.steps || []).forEach(s => {
          const type = s.maneuver ? s.maneuver.type : '';
          const mod  = s.maneuver ? (s.maneuver.modifier || '') : '';
          const inst = s.name
            ? (type === 'turn' ? 'Turn ' + mod + ' onto ' + s.name
                : type === 'arrive' ? 'Arrive at destination'
                : 'Continue on ' + s.name)
            : (type === 'arrive' ? 'Arrive at destination' : 'Continue straight');
          steps.push({ instruction: inst, distance: s.distance || 0 });
        });
      });
      stepIdx = 0;
      if (steps.length) {
        document.getElementById('instruction-text').textContent = steps[0].instruction;
        document.getElementById('distance-text').textContent    = formatDist(steps[0].distance);
      }
    }).catch(() => {});
}

function advanceStep(lat, lng) {
  if (!steps.length || stepIdx >= steps.length) return;
  const s = steps[stepIdx];
  document.getElementById('instruction-text').textContent = s.instruction;
  document.getElementById('distance-text').textContent    = formatDist(s.distance);
  // Advance to next step when within ~40 m of the current waypoint
  // (simple proximity: decrement remaining distance by movement)
  if (s.distance < 40 && stepIdx < steps.length - 1) {
    stepIdx++;
  } else if (s.distance > 0) {
    steps[stepIdx].distance = Math.max(0, s.distance - 20);
  }
}

function formatDist(m) {
  return m >= 1000 ? (m/1000).toFixed(1)+' km' : Math.round(m)+' m';
}

function recenterMap() {
  if (lastLat) map.setView([lastLat, lastLng], 15);
}

function toggleSheet() {
  sheetExpanded = !sheetExpanded;
  document.getElementById('bottom-sheet').style.maxHeight = sheetExpanded ? '55vh' : '110px';
}

function updateStatus(status) {
  fetch(CTX+'/trips/update-status', {
    method:'POST',
    headers:{'Content-Type':'application/x-www-form-urlencoded'},
    body:'tripId='+TRIP_ID+'&status='+status
  }).then(()=>location.reload()).catch(()=>{});
}

function openDelay()  { document.getElementById('delay-modal').classList.add('open'); }
function closeDelay() { document.getElementById('delay-modal').classList.remove('open'); }

function sendDelay() {
  const msg = document.getElementById('delay-msg').value.trim();
  if (!msg) return;
  fetch(CTX+'/notifications/delay', {
    method:'POST',
    headers:{'Content-Type':'application/x-www-form-urlencoded'},
    body:'tripId='+TRIP_ID+'&message='+encodeURIComponent(msg)
  }).then(()=>{ closeDelay(); document.getElementById('delay-msg').value=''; }).catch(()=>{});
}

function sendGps(lat, lng) {
  fetch(CTX+'/tracking/update', {
    method:'POST',
    headers:{'Content-Type':'application/x-www-form-urlencoded'},
    body:'tripId='+TRIP_ID+'&lat='+lat+'&lng='+lng
  }).catch(()=>{});
}

window.addEventListener('load', initMap);

// ── AI Delay Risk polling ─────────────────────────────────────────────────
function pollDelayRisk() {
  fetch(CTX+'/ai/delay-risk?tripId='+TRIP_ID)
    .then(r=>r.json())
    .then(d=>{
      const banner = document.getElementById('ai-risk-banner');
      if (!d.risk || d.risk === 'LOW') {
        banner.classList.remove('visible');
        return;
      }
      banner.className = 'visible risk-'+d.risk;
      document.getElementById('ai-risk-icon').textContent = d.risk === 'HIGH' ? '🚨' : '⚠️';
      document.getElementById('ai-risk-msg').textContent =
        d.risk === 'HIGH' ? 'High delay risk detected on this segment' : 'Moderate slowdown detected ahead';
      document.getElementById('ai-risk-conf').textContent =
        (d.confidence ? d.confidence : '--') + ' confidence · AI prediction';
    }).catch(()=>{});
}
setInterval(pollDelayRisk, 30000);
setTimeout(pollDelayRisk, 5000);
</script>
</body>
</html>
