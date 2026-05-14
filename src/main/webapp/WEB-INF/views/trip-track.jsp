<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
  String googleMapsKey = System.getenv("GOOGLE_MAPS_API_KEY");
  if (googleMapsKey == null) googleMapsKey = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<title>CommuteSafe – Live Track</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css"/>
<style>
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:"Segoe UI",sans-serif; height:100vh; overflow:hidden; }
  #map { position:fixed; inset:0; z-index:0; }
  #topbar {
    position:fixed; top:0; left:0; right:0; z-index:500;
    display:flex; align-items:center; gap:10px; padding:12px 16px;
    background:linear-gradient(180deg,rgba(255,255,255,0.95) 0%,rgba(255,255,255,0) 100%);
    pointer-events:none;
  }
  #topbar > * { pointer-events:all; }
  .back-btn {
    width:40px;height:40px;border-radius:50%;border:none;
    background:white;color:#111;font-size:1.1rem;
    display:flex;align-items:center;justify-content:center;cursor:pointer;
    box-shadow:0 2px 10px rgba(0,0,0,0.15);
  }
  .back-btn:hover { background:#f3f4f6; }
  .route-pill {
    background:white;color:#111;border-radius:20px;
    padding:6px 14px;font-size:0.85rem;font-weight:700;
    box-shadow:0 2px 10px rgba(0,0,0,0.12);
  }
  #status-chip {
    margin-left:auto;border-radius:20px;padding:5px 12px;font-size:0.78rem;
    font-weight:700;display:flex;align-items:center;gap:5px;
    background:#dcfce7;color:#15803d;
  }
  .live-dot { width:7px;height:7px;border-radius:50%;background:#22c55e;animation:blink 1.2s infinite; }
  @keyframes blink { 0%,100%{opacity:1} 50%{opacity:0.3} }
  #delay-banner {
    display:none;position:fixed;top:68px;left:16px;right:16px;z-index:450;
    background:#fff3cd;border-left:5px solid #f39c12;border-radius:10px;
    padding:12px 16px;font-size:0.85rem;color:#7d5a00;
    box-shadow:0 2px 12px rgba(0,0,0,0.12);
  }
  #delay-banner.visible { display:block; }
  /* AI Chat */
  #ai-fab {
    position:fixed;bottom:200px;right:14px;z-index:600;
    width:50px;height:50px;border-radius:50%;border:none;
    background:linear-gradient(135deg,#6366f1,#8b5cf6);
    color:white;font-size:1.25rem;cursor:pointer;
    box-shadow:0 4px 18px rgba(99,102,241,0.55);
    display:flex;align-items:center;justify-content:center;
    transition:transform 0.2s;
  }
  #ai-fab:hover{transform:scale(1.1);}
  #ai-panel {
    position:fixed;right:0;top:0;bottom:0;width:min(340px,100vw);
    z-index:800;background:white;
    box-shadow:-4px 0 30px rgba(0,0,0,0.2);
    display:flex;flex-direction:column;
    transform:translateX(100%);transition:transform 0.3s ease;
  }
  #ai-panel.open{transform:translateX(0);}
  .ai-header{
    padding:14px 16px;display:flex;align-items:center;justify-content:space-between;
    background:linear-gradient(135deg,#6366f1,#8b5cf6);color:white;flex-shrink:0;
  }
  .ai-title{font-weight:700;font-size:0.95rem;display:flex;align-items:center;gap:8px;}
  .ai-close{background:none;border:none;color:white;font-size:1.1rem;cursor:pointer;padding:4px;}
  #ai-messages{
    flex:1;overflow-y:auto;padding:14px;
    display:flex;flex-direction:column;gap:10px;background:#f8fafc;
  }
  .ai-msg{max-width:86%;padding:10px 13px;border-radius:14px;font-size:0.84rem;line-height:1.5;}
  .ai-user{background:#6366f1;color:white;border-radius:14px 14px 4px 14px;align-self:flex-end;}
  .ai-bot{background:white;color:#111;border:1px solid #e5e7eb;border-radius:14px 14px 14px 4px;align-self:flex-start;}
  .ai-sys{background:#f0fdf4;color:#14532d;border:1px solid #bbf7d0;border-radius:10px;align-self:center;text-align:center;font-size:0.77rem;}
  .ai-typing{display:flex;gap:4px;align-items:center;padding:10px 13px;}
  .ai-typing span{width:6px;height:6px;border-radius:50%;background:#6366f1;animation:dot-bounce 1s infinite;}
  .ai-typing span:nth-child(2){animation-delay:.15s;}.ai-typing span:nth-child(3){animation-delay:.3s;}
  @keyframes dot-bounce{0%,80%,100%{transform:translateY(0)}40%{transform:translateY(-6px)}}
  #ai-input-row{display:flex;gap:8px;padding:12px;border-top:1px solid #e5e7eb;background:white;flex-shrink:0;}
  #ai-input{flex:1;border:1px solid #e5e7eb;border-radius:20px;padding:9px 14px;font-size:0.84rem;outline:none;}
  #ai-input:focus{border-color:#6366f1;}
  #ai-send{width:38px;height:38px;border-radius:50%;border:none;background:#6366f1;color:white;cursor:pointer;font-size:0.88rem;display:flex;align-items:center;justify-content:center;}
  .ai-eta-row{display:flex;gap:8px;margin-top:10px;}
  .ai-chip{flex:1;display:flex;align-items:center;gap:6px;background:#f8fafc;border:1px solid #e5e7eb;border-radius:10px;padding:8px 10px;font-size:0.77rem;}
  .ai-chip i{color:#6366f1;}
  #map-controls {
    position:fixed;right:14px;top:50%;transform:translateY(-50%);
    z-index:400;display:flex;flex-direction:column;gap:8px;
  }
  .map-btn { 
    width:42px;height:42px;border-radius:12px;border:none;
    background:white;color:#111;font-size:1.2rem;
    display:flex;align-items:center;justify-content:center;cursor:pointer;
    box-shadow:0 2px 10px rgba(0,0,0,0.15);
  }
  .map-btn:hover { background:#f3f4f6; }
  .map-btn.active { background:#0f172a; color:white; }
  #bottom-sheet {
    position:fixed;bottom:0;left:0;right:0;z-index:500;
    background:white;border-radius:24px 24px 0 0;
    box-shadow:0 -4px 30px rgba(0,0,0,0.18);
    max-height:55vh;overflow:hidden;display:flex;flex-direction:column;
    transition:max-height 0.3s ease;
  }
  #sheet-handle { flex-shrink:0;padding:10px 0 4px;display:flex;justify-content:center;cursor:pointer; }
  .handle-bar { width:40px;height:4px;border-radius:2px;background:#ddd; }
  #sheet-inner { overflow-y:auto;flex:1;padding:0 16px 24px; }
  #bus-status-card {
    background:#f0fdf4;border-radius:14px;padding:14px 16px;margin-bottom:16px;
    display:flex;align-items:center;gap:12px;border:1.5px solid #bbf7d0;
  }
  .bus-icon-wrap {
    width:44px;height:44px;border-radius:50%;background:#22c55e;color:white;
    font-size:1.2rem;display:flex;align-items:center;justify-content:center;flex-shrink:0;
  }
  #bus-status-text { font-weight:700;font-size:0.95rem;color:#14532d; }
  #bus-status-sub  { font-size:0.78rem;color:#16a34a;margin-top:2px; }
  #info-row { display:flex;gap:10px;margin-bottom:14px; }
  .info-chip {
    flex:1;background:#f8fafc;border-radius:10px;padding:10px 12px;
    font-size:0.78rem;color:#374151;border:1px solid #e5e7eb;
  }
  .info-chip .label { font-weight:700;margin-bottom:2px;color:#111; }
  #eta-card {
    background:linear-gradient(135deg,#0f172a,#1e3a5f);border-radius:16px;
    padding:16px 18px;margin-bottom:14px;color:white;display:flex;align-items:center;gap:14px;
  }
  #eta-card .eta-icon {
    width:48px;height:48px;border-radius:50%;background:rgba(255,255,255,0.12);
    display:flex;align-items:center;justify-content:center;font-size:1.4rem;flex-shrink:0;
  }
  #eta-mins { font-size:2rem;font-weight:900;line-height:1; }
  #eta-label { font-size:0.72rem;color:rgba(255,255,255,0.65);margin-top:2px; }
  #dest-name { font-size:0.88rem;font-weight:700;margin-top:4px; }
  #dist-label { font-size:0.75rem;color:rgba(255,255,255,0.6);margin-top:1px; }
</style>
</head>
<body>
<div id="map"></div>
<div id="topbar">
  <button class="back-btn" onclick="if(history.length>1&&document.referrer)history.back();else location.href='${pageContext.request.contextPath}/passenger/dashboard';"><i class="bi bi-arrow-left"></i></button>
  <div class="route-pill"><i class="bi bi-bus-front-fill" style="color:#22c55e"></i> ${trip.route.routeName}</div>
  <div id="status-chip">
    <div class="live-dot"></div>
    <span id="live-label">Waiting…</span>
  </div>
</div>
<div id="delay-banner">
  <strong>⚠️ Delay Reported</strong>
  <div id="delay-msg-text">The driver has reported a delay on this route.</div>
  <button onclick="document.getElementById('delay-banner').classList.remove('visible');document.getElementById('alt-panel').style.display='none';"
    style="float:right;background:none;border:none;cursor:pointer;margin-top:-20px;color:#7d5a00;font-size:1rem">✕</button>
</div>
<!-- Alternative buses panel -->
<div id="alt-panel" style="display:none;position:fixed;top:130px;left:12px;right:12px;z-index:450;
     background:#fff;border-radius:16px;box-shadow:0 4px 24px rgba(0,0,0,0.15);padding:16px;max-height:260px;overflow-y:auto;">
  <div style="font-weight:700;font-size:.9rem;margin-bottom:12px;color:#111">
    <i class="bi bi-arrow-left-right me-1" style="color:#3b82f6"></i> Alternative Buses
  </div>
  <div id="alt-list"></div>
</div>
<!-- AI Chat floating button -->
<button id="ai-fab" onclick="toggleAiPanel()" title="Ask AI assistant"><i class="bi bi-stars"></i></button>
<!-- AI Chat Panel -->
<div id="ai-panel">
  <div class="ai-header">
    <div class="ai-title"><i class="bi bi-robot"></i> CommuteSafe AI</div>
    <button class="ai-close" onclick="toggleAiPanel()"><i class="bi bi-x-lg"></i></button>
  </div>
  <div id="ai-messages">
    <div class="ai-msg ai-sys">👋 Hi! I'm your CommuteSafe AI. Ask me anything about your journey — ETA, delays, stops, or anything else.</div>
  </div>
  <div id="ai-input-row">
    <input type="text" id="ai-input" placeholder="Ask about your bus…" onkeydown="if(event.key==='Enter')sendAiMsg()">
    <button id="ai-send" onclick="sendAiMsg()"><i class="bi bi-send-fill"></i></button>
  </div>
</div>
<div id="map-controls">
  <button class="map-btn" onclick="map.zoomIn()"><i class="bi bi-plus"></i></button>
  <button class="map-btn" onclick="map.zoomOut()"><i class="bi bi-dash"></i></button>
  <button class="map-btn active" id="follow-btn" onclick="toggleFollow()" title="Auto-follow bus"><i class="bi bi-record-circle"></i></button>
  <button class="map-btn" onclick="recenterBus()" title="Re-center on bus"><i class="bi bi-crosshair2"></i></button>
</div>
<div id="bottom-sheet">
  <div id="sheet-handle" onclick="toggleSheet()"><div class="handle-bar"></div></div>
  <div id="sheet-inner">
    <!-- ETA Card -->
    <div id="eta-card">
      <div class="eta-icon"><i class="bi bi-clock-fill"></i></div>
      <div>
        <div style="display:flex;align-items:baseline;gap:5px;">
          <span id="eta-mins">--</span>
          <span style="font-size:0.85rem;font-weight:600;color:rgba(255,255,255,0.75)">min</span>
        </div>
        <div id="eta-label">Calculating ETA…</div>
        <div id="dest-name"><i class="bi bi-geo-alt-fill" style="color:#f87171"></i> ${trip.route.endLocation}</div>
        <div id="dist-label">-- km remaining</div>
      </div>
    </div>
    <div id="info-row">
      <div class="info-chip">
        <div class="label">${trip.driver.name}</div>
        <div>Driver</div>
      </div>
      <div class="info-chip">
        <div class="label">${trip.bus.registrationNumber}</div>
        <div>Bus</div>
      </div>
    </div>
    <div id="bus-status-card">
      <div class="bus-icon-wrap"><i class="bi bi-bus-front-fill"></i></div>
      <div>
        <div id="bus-status-text">Locating bus…</div>
        <div id="bus-status-sub">Locating…</div>
      </div>
    </div>    <!-- AI Speed / Traffic Chips -->
    <div class="ai-eta-row">
      <div class="ai-chip"><i class="bi bi-speedometer2"></i><span id="ai-speed-val">-- km/h</span></div>
      <div class="ai-chip"><i class="bi bi-activity"></i><span id="ai-traffic-val">Calculating…</span></div>
    </div>    <div style="font-size:0.75rem;font-weight:700;color:#888;text-transform:uppercase;letter-spacing:0.06em;margin-bottom:6px;">Route</div>
    <div style="font-size:0.9rem;color:#374151;padding:6px 0;">
      <i class="bi bi-circle-fill" style="color:#22c55e;font-size:0.5rem"></i>
      &nbsp;${trip.route.startLocation}
      &nbsp;→&nbsp;
      <i class="bi bi-geo-alt-fill" style="color:#ef4444"></i>
      &nbsp;${trip.route.endLocation}
    </div>
  </div>
</div>

<script>
const TRIP_ID = ${trip.tripId};
const CTX     = '${pageContext.request.contextPath}';

const ROUTE_START_LAT = '${trip.route.startLat}' !== '' ? parseFloat('${trip.route.startLat}') : null;
const ROUTE_START_LNG = '${trip.route.startLng}' !== '' ? parseFloat('${trip.route.startLng}') : null;
const ROUTE_END_LAT   = '${trip.route.endLat}'   !== '' ? parseFloat('${trip.route.endLat}')   : null;
const ROUTE_END_LNG   = '${trip.route.endLng}'   !== '' ? parseFloat('${trip.route.endLng}')   : null;

let map, busMarker;
let busLat = null, busLng = null;
let sheetExpanded = true;
let autoFollow = true;
let lastDynZoom = -1;
let currentHeading = 0;
let camAnimFrame = null;

// ── Dynamic camera profile ──────────────────────────────────────────────────
function dynamicCamera(speedKmh) {
  if (speedKmh < 3)   return { zoom:19, tilt:  0 }; // stopped — top-down
  if (speedKmh < 15)  return { zoom:18, tilt: 30 }; // slow / intersection
  if (speedKmh < 45)  return { zoom:17, tilt: 45 }; // normal urban
  if (speedKmh < 80)  return { zoom:16, tilt: 52 }; // fast urban
  if (speedKmh < 110) return { zoom:15, tilt: 58 }; // highway
  return                     { zoom:14, tilt: 67 }; // fast highway
}

// Bearing between two GPS points
function calcHeading(from, to) {
  const toRad = d => d * Math.PI / 180;
  const dLng  = toRad(to.lng - from.lng);
  const y = Math.sin(dLng) * Math.cos(toRad(to.lat));
  const x = Math.cos(toRad(from.lat)) * Math.sin(toRad(to.lat))
           - Math.sin(toRad(from.lat)) * Math.cos(toRad(to.lat)) * Math.cos(dLng);
  return (Math.atan2(y, x) * 180 / Math.PI + 360) % 360;
}

// Smooth camera animation (Google Maps lacks built-in flyTo)
function smoothCamera(toLat, toLng, targetZoom, targetTilt, targetHeading) {
  if (camAnimFrame) cancelAnimationFrame(camAnimFrame);
  const startZoom    = map.getZoom();
  const startTilt    = map.getTilt()    || 0;
  const startCenter  = map.getCenter();
  const startLat     = startCenter.lat();
  const startLng     = startCenter.lng();
  const t0 = performance.now();
  const dur = 1400;
  (function step(now) {
    const t    = Math.min((now - t0) / dur, 1);
    const ease = t < 0.5 ? 2*t*t : -1+(4-2*t)*t;
    map.moveCamera({
      center:  { lat: startLat + (toLat - startLat)*ease,
                 lng: startLng + (toLng - startLng)*ease },
      zoom:    startZoom + (targetZoom - startZoom) * ease,
      tilt:    startTilt + (targetTilt - startTilt) * ease,
      heading: targetHeading
    });
    if (t < 1) camAnimFrame = requestAnimationFrame(step);
  })(t0);
}

function applyDynamicView(lat, lng, speedKmh) {
  if (!autoFollow) return;
  const cam = dynamicCamera(speedKmh);
  const heading = speedKmh > 5 ? currentHeading : (map.getHeading() || 0);
  if (Math.abs(map.getZoom() - cam.zoom) >= 0.5 || lastDynZoom !== cam.zoom) {
    smoothCamera(lat, lng, cam.zoom, cam.tilt, heading);
    lastDynZoom = cam.zoom;
  } else {
    map.moveCamera({ center:{lat,lng}, tilt:cam.tilt, heading, zoom:cam.zoom });
  }
}

function toggleFollow() {
  autoFollow = !autoFollow;
  const btn = document.getElementById('follow-btn');
  btn.classList.toggle('active', autoFollow);
  btn.title = autoFollow ? 'Auto-follow ON' : 'Auto-follow OFF';
  if (autoFollow && busLat !== null) recenterBus();
}
function onMapDrag() { if (autoFollow) toggleFollow(); }

// ── Dead-reckoning ───────────────────────────────────────────────────────
let prevGps = null, velLat = 0, velLng = 0, drRafId = null;

function haversineKm(a, b) {
  const R = 6371, toRad = d => d * Math.PI / 180;
  const dLat = toRad(b.lat-a.lat), dLng = toRad(b.lng-a.lng);
  const h = Math.sin(dLat/2)**2 + Math.cos(toRad(a.lat))*Math.cos(toRad(b.lat))*Math.sin(dLng/2)**2;
  return R * 2 * Math.asin(Math.sqrt(h));
}

function startDeadReckoning() {
  if (drRafId) cancelAnimationFrame(drRafId);
  (function dr() {
    if (busMarker && prevGps && (velLat || velLng)) {
      const clamp = Math.min(performance.now() - prevGps.ts, 15000);
      const lat = prevGps.lat + velLat * clamp;
      const lng = prevGps.lng + velLng * clamp;
      busMarker.position = { lat, lng };
      busLat = lat; busLng = lng;
    }
    drRafId = requestAnimationFrame(dr);
  })();
}

// ── Map initialisation ────────────────────────────────────────────────────────
function initMap() {
  const initCenter = (ROUTE_START_LAT && ROUTE_START_LNG)
    ? { lat: ROUTE_START_LAT, lng: ROUTE_START_LNG }
    : { lat: -25.7313, lng: 28.1648 };

  const { Map } = google.maps;
  const { AdvancedMarkerElement } = google.maps.marker;

  map = new Map(document.getElementById('map'), {
    center:     initCenter,
    zoom:       13,
    tilt:       0,
    heading:    0,
    mapId:      'DEMO_MAP_ID',
    mapTypeId:  'roadmap',
    disableDefaultUI: true,
    gestureHandling: 'greedy'
  });

  map.addListener('dragstart', onMapDrag);

  // Route endpoint markers
  function dotMarker(color) {
    const el = document.createElement('div');
    el.style.cssText = 'width:14px;height:14px;border-radius:50%;background:'+color+';border:2.5px solid white;box-shadow:0 1px 6px rgba(0,0,0,.35)';
    return el;
  }
  if (ROUTE_START_LAT && ROUTE_START_LNG)
    new AdvancedMarkerElement({ map, position:{lat:ROUTE_START_LAT,lng:ROUTE_START_LNG}, content:dotMarker('#22c55e'), title:'${trip.route.startLocation}' });
  if (ROUTE_END_LAT && ROUTE_END_LNG)
    new AdvancedMarkerElement({ map, position:{lat:ROUTE_END_LAT,lng:ROUTE_END_LNG}, content:dotMarker('#f87171'), title:'${trip.route.endLocation}' });

  // Fit to route bounds
  if (ROUTE_START_LAT && ROUTE_END_LAT) {
    const bounds = new google.maps.LatLngBounds();
    bounds.extend({lat:ROUTE_START_LAT,lng:ROUTE_START_LNG});
    bounds.extend({lat:ROUTE_END_LAT,  lng:ROUTE_END_LNG});
    map.fitBounds(bounds, 60);
  }

  pollBus();
  setInterval(pollBus, 2000);
  setInterval(pollDelay, 15000);
  pollDelay();
  startDeadReckoning();
}

function makeBusEl(live) {
  const el = document.createElement('div');
  el.style.cssText =
    'width:44px;height:44px;border-radius:50%;transition:background .3s,box-shadow .3s;' +
    'border:3px solid white;display:flex;align-items:center;justify-content:center;' +
    'color:white;font-size:1.2rem;' +
    'background:'   + (live ? '#22c55e' : '#94a3b8') + ';' +
    'box-shadow:'   + (live ? '0 0 0 10px rgba(34,197,94,.2),0 2px 14px rgba(0,0,0,.3)'
                            : '0 2px 8px rgba(0,0,0,.2)');
  el.innerHTML = '<i class="bi bi-bus-front-fill"></i>';
  return el;
}
function updateBusMarkerLive(live) {
  if (!busMarker) return;
  const el = busMarker.content;
  el.style.background = live ? '#22c55e' : '#94a3b8';
  el.style.boxShadow  = live ? '0 0 0 10px rgba(34,197,94,.2),0 2px 14px rgba(0,0,0,.3)'
                             : '0 2px 8px rgba(0,0,0,.2)';
}

function pollBus() {
  fetch(CTX+'/tracking/latest?tripId='+TRIP_ID)
    .then(r=>r.json())
    .then(d=>{
      if (!d.found) {
        document.getElementById('live-label').textContent='Waiting…';
        document.getElementById('status-chip').style.background='#fef9c3';
        document.getElementById('status-chip').style.color='#854d0e';
        document.getElementById('bus-status-text').textContent='Waiting for driver location…';
        document.getElementById('bus-status-sub').textContent='Driver may still be granting GPS access';
        velLat=0; velLng=0; updateBusMarkerLive(false); return;
      }
      const nowMs = performance.now();
      const newFix = { lat:d.lat, lng:d.lng, ts:nowMs };
      let speedKmh = 0;
      if (prevGps) {
        const dtMs = nowMs - prevGps.ts;
        if (dtMs > 100) {
          speedKmh = (haversineKm(prevGps,newFix) / dtMs) * 3600000;
          if (speedKmh > 1) {
            velLat = (d.lat-prevGps.lat)/dtMs;
            velLng = (d.lng-prevGps.lng)/dtMs;
            currentHeading = calcHeading(prevGps, newFix);
          } else { velLat=0; velLng=0; }
          document.getElementById('bus-status-sub').textContent =
            speedKmh > 1 ? speedKmh.toFixed(0)+' km/h · Live' : 'Stopped · Live';
        }
      } else {
        document.getElementById('bus-status-sub').textContent = 'Live';
      }
      prevGps = newFix;
      document.getElementById('live-label').textContent = 'Live';
      document.getElementById('status-chip').style.background = '#dcfce7';
      document.getElementById('status-chip').style.color = '#15803d';
      document.getElementById('bus-status-text').textContent = 'Bus is live';
      const { AdvancedMarkerElement } = google.maps.marker;
      if (!busMarker) {
        busMarker = new AdvancedMarkerElement({ map, position:{lat:d.lat,lng:d.lng}, content:makeBusEl(true) });
        busLat=d.lat; busLng=d.lng;
        map.moveCamera({ center:{lat:d.lat,lng:d.lng}, zoom:19, tilt:0 });
        lastDynZoom = 19;
      } else {
        updateBusMarkerLive(true);
        busMarker.position = { lat:d.lat, lng:d.lng };
        busLat=d.lat; busLng=d.lng;
        applyDynamicView(d.lat, d.lng, speedKmh);
      }
    }).catch(()=>{});
}

function recenterBus() {
  if (busLat !== null) {
    autoFollow = true;
    document.getElementById('follow-btn').classList.add('active');
    smoothCamera(busLat, busLng, lastDynZoom>0?lastDynZoom:17, 45, currentHeading);
  }
}

function toggleSheet() {
  sheetExpanded = !sheetExpanded;
  document.getElementById('bottom-sheet').style.maxHeight = sheetExpanded ? '55vh' : '110px';
}

var delayDismissed = false;
function pollDelay() {
  fetch(CTX+'/notifications/latest-delay?tripId='+TRIP_ID)
    .then(r=>r.json()).then(d=>{
      if (d.hasDelay && !delayDismissed) {
        document.getElementById('delay-banner').classList.add('visible');
        document.getElementById('delay-msg-text').textContent = d.message||'The driver has reported a delay.';
        fetchAlternatives();
      }
    }).catch(()=>{});
}
var altsFetched = false;
function fetchAlternatives() {
  if (altsFetched) return; altsFetched=true;
  fetch(CTX+'/trips/alternatives?tripId='+TRIP_ID).then(r=>r.json()).then(alts=>{
    if (!alts||!alts.length) return;
    const list = document.getElementById('alt-list');
    list.innerHTML = alts.map(t=>{
      const isLive = t.status==='IN_PROGRESS';
      const badge = isLive
        ? '<span style="background:#dcfce7;color:#16a34a;border-radius:20px;padding:2px 8px;font-size:.7rem;font-weight:800">LIVE</span>'
        : '<span style="background:#ede9fe;color:#7c3aed;border-radius:20px;padding:2px 8px;font-size:.7rem;font-weight:800">'+t.startTime+'</span>';
      const link = isLive
        ? '<a href="'+CTX+'/tracking/view?tripId='+t.tripId+'" style="background:#1a1a1a;color:#fff;border-radius:10px;padding:7px 14px;font-size:.8rem;font-weight:700;text-decoration:none;white-space:nowrap">Track</a>'
        : '<span style="background:#e5e7eb;color:#9ca3af;border-radius:10px;padding:7px 14px;font-size:.8rem;font-weight:700">Soon</span>';
      return '<div style="display:flex;align-items:center;gap:10px;padding:10px 0;border-bottom:1px solid #f0f0f0">'
        +'<div style="flex:1"><div style="font-weight:700;font-size:.88rem">'+t.route+'</div>'
        +'<div style="font-size:.75rem;color:#888">'+t.from+' → '+t.to+'</div>'
        +'<div style="font-size:.75rem;color:#aaa;margin-top:2px">'+t.driver+' · '+t.bus+'</div></div>'
        +badge+' '+link+'</div>';
    }).join('');
    document.getElementById('alt-panel').style.display='block';
  }).catch(()=>{});
}

// ── AI Chat ───────────────────────────────────────────────────────────────────
let aiOpen = false;
function toggleAiPanel() {
  aiOpen = !aiOpen;
  document.getElementById('ai-panel').classList.toggle('open', aiOpen);
}
function sendAiMsg() {
  const input = document.getElementById('ai-input');
  const msg = input.value.trim(); if (!msg) return;
  input.value = '';
  appendAiMsg(msg, true);
  const typing = appendTypingIndicator();
  fetch(CTX+'/ai/chat', { method:'POST',
    headers:{'Content-Type':'application/x-www-form-urlencoded'},
    body:'tripId='+TRIP_ID+'&message='+encodeURIComponent(msg)
  }).then(r=>r.json()).then(d=>{
    typing.remove(); appendAiMsg(d.reply||d.error||'Sorry, no response.', false);
  }).catch(()=>{ typing.remove(); appendAiMsg('Could not reach AI. Check your connection.', false); });
}
function appendAiMsg(text, isUser) {
  const div = document.createElement('div');
  div.className = 'ai-msg '+(isUser?'ai-user':'ai-bot');
  div.textContent = text;
  const msgs = document.getElementById('ai-messages');
  msgs.appendChild(div); msgs.scrollTop = msgs.scrollHeight;
  return div;
}
function appendTypingIndicator() {
  const div = document.createElement('div');
  div.className = 'ai-msg ai-bot ai-typing';
  div.innerHTML = '<span></span><span></span><span></span>';
  const msgs = document.getElementById('ai-messages');
  msgs.appendChild(div); msgs.scrollTop = msgs.scrollHeight;
  return div;
}
function pollAiEta() {
  fetch(CTX+'/ai/eta?tripId='+TRIP_ID).then(r=>r.json()).then(d=>{
    document.getElementById('ai-speed-val').textContent =
      d.speedKmh ? parseFloat(d.speedKmh).toFixed(0)+' km/h' : '-- km/h';
    document.getElementById('ai-traffic-val').textContent = d.label||'--';
    if (d.etaMinutes > 0) {
      const mins = Math.round(d.etaMinutes);
      document.getElementById('eta-mins').textContent = mins<1?'<1':mins;
      if (mins<=2) {
        document.getElementById('eta-label').textContent = 'Arriving soon';
      } else {
        const now = new Date();
        now.setMinutes(now.getMinutes()+mins);
        document.getElementById('eta-label').textContent =
          'Est. arrival at '+now.getHours().toString().padStart(2,'0')+':'
          +now.getMinutes().toString().padStart(2,'0');
      }
    } else {
      document.getElementById('eta-mins').textContent = '--';
      document.getElementById('eta-label').textContent = 'ETA unavailable';
    }
    if (d.distKm>0)
      document.getElementById('dist-label').textContent = parseFloat(d.distKm).toFixed(1)+' km remaining';
  }).catch(()=>{});
}
setInterval(pollAiEta, 15000);
pollAiEta();
</script>
<script async
  src="https://maps.googleapis.com/maps/api/js?key=<%= googleMapsKey %>&libraries=marker&callback=initMap&loading=async">
</script>
</body>
</html>
