<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<title>SmartBus – Live Track</title>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
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
  <button onclick="document.getElementById('delay-banner').classList.remove('visible')"
    style="float:right;background:none;border:none;cursor:pointer;margin-top:-20px;color:#7d5a00;font-size:1rem">✕</button>
</div>
<!-- AI Chat floating button -->
<button id="ai-fab" onclick="toggleAiPanel()" title="Ask AI assistant"><i class="bi bi-stars"></i></button>
<!-- AI Chat Panel -->
<div id="ai-panel">
  <div class="ai-header">
    <div class="ai-title"><i class="bi bi-robot"></i> SmartBus AI</div>
    <button class="ai-close" onclick="toggleAiPanel()"><i class="bi bi-x-lg"></i></button>
  </div>
  <div id="ai-messages">
    <div class="ai-msg ai-sys">👋 Hi! I'm your SmartBus AI. Ask me anything about your journey — ETA, delays, stops, or anything else.</div>
  </div>
  <div id="ai-input-row">
    <input type="text" id="ai-input" placeholder="Ask about your bus…" onkeydown="if(event.key==='Enter')sendAiMsg()">
    <button id="ai-send" onclick="sendAiMsg()"><i class="bi bi-send-fill"></i></button>
  </div>
</div>
<div id="map-controls">
  <button class="map-btn" onclick="map.zoomIn()"><i class="bi bi-plus"></i></button>
  <button class="map-btn" onclick="map.zoomOut()"><i class="bi bi-dash"></i></button>
  <button class="map-btn" onclick="recenterBus()"><i class="bi bi-crosshair2"></i></button>
</div>
<div id="bottom-sheet">
  <div id="sheet-handle" onclick="toggleSheet()"><div class="handle-bar"></div></div>
  <div id="sheet-inner">
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

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
const TRIP_ID = ${trip.tripId};
const CTX     = '${pageContext.request.contextPath}';

let map, busMarker;
let busLat = null, busLng = null;
let sheetExpanded = true;

// ── Dead-reckoning state ────────────────────────────────────────────────────
// prevGps: last confirmed GPS fix {lat, lng, ts (ms)}
// velLat/velLng: velocity in degrees/ms from two consecutive fixes
// drRafId: requestAnimationFrame handle for the DR loop
let prevGps = null, velLat = 0, velLng = 0, drRafId = null;

// Haversine distance in km between two lat/lng points
function haversineKm(a, b) {
  const R = 6371, toRad = d => d * Math.PI / 180;
  const dLat = toRad(b.lat - a.lat), dLng = toRad(b.lng - a.lng);
  const h = Math.sin(dLat/2)**2 + Math.cos(toRad(a.lat))*Math.cos(toRad(b.lat))*Math.sin(dLng/2)**2;
  return R * 2 * Math.asin(Math.sqrt(h));
}

// Start/restart the dead-reckoning RAF loop
function startDeadReckoning() {
  if (drRafId) cancelAnimationFrame(drRafId);
  function dr() {
    if (busMarker && prevGps && (velLat !== 0 || velLng !== 0)) {
      const elapsed = performance.now() - prevGps.ts;
      // Don't extrapolate beyond 10 s (bus might have stopped)
      const clamp = Math.min(elapsed, 10000);
      const lat = prevGps.lat + velLat * clamp;
      const lng = prevGps.lng + velLng * clamp;
      busMarker.setLatLng([lat, lng]);
      busLat = lat; busLng = lng;
    }
    drRafId = requestAnimationFrame(dr);
  }
  drRafId = requestAnimationFrame(dr);
}

function initMap() {
  map = L.map('map', { zoomControl:false, attributionControl:false });
  L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', { maxZoom:19 }).addTo(map);
  map.setView([3.1390, 101.6869], 13);
  pollBus();
  setInterval(pollBus, 3000);
  setInterval(pollDelay, 15000);
  pollDelay();
  startDeadReckoning();
}

function busIcon(live) {
  const col = live ? '#22c55e' : '#94a3b8';
  const shadow = live ? '0 0 0 8px rgba(34,197,94,0.25)' : '0 2px 6px rgba(0,0,0,0.2)';
  return L.divIcon({
    className:'',
    html:'<div style="width:40px;height:40px;border-radius:50%;background:'+col+';border:3px solid white;display:flex;align-items:center;justify-content:center;color:white;font-size:1.15rem;box-shadow:'+shadow+'"><i class=\'bi bi-bus-front-fill\'></i></div>',
    iconSize:[40,40], iconAnchor:[20,20]
  });
}

function pollBus() {
  fetch(CTX+'/tracking/latest?tripId='+TRIP_ID)
    .then(r=>r.json())
    .then(d=>{
      if (!d.found) {
        document.getElementById('live-label').textContent='Offline';
        document.getElementById('status-chip').style.background='#fee2e2';
        document.getElementById('status-chip').style.color='#b91c1c';
        document.getElementById('bus-status-text').textContent='Bus is offline';
        velLat = 0; velLng = 0; // stop extrapolating
        if (busMarker) busMarker.setIcon(busIcon(false));
        return;
      }
      const nowMs = performance.now();
      const newFix = { lat: d.lat, lng: d.lng, ts: nowMs };

      // Calculate velocity from two consecutive fixes
      if (prevGps) {
        const dtMs = nowMs - prevGps.ts;
        if (dtMs > 100) { // ignore duplicate/too-fast responses
          const dLat = d.lat - prevGps.lat;
          const dLng = d.lng - prevGps.lng;
          const distKm = haversineKm(prevGps, newFix);
          const speedKmh = (distKm / dtMs) * 3600000;
          // Only extrapolate when actually moving (>1 km/h); if stopped, zero velocity
          if (speedKmh > 1) {
            velLat = dLat / dtMs;
            velLng = dLng / dtMs;
          } else {
            velLat = 0; velLng = 0;
          }
          // Show live speed in status
          document.getElementById('bus-status-sub').textContent =
            speedKmh > 1 ? speedKmh.toFixed(0) + ' km/h · Live' : 'Stopped · Live';
        }
      } else {
        document.getElementById('bus-status-sub').textContent = 'Live';
      }
      prevGps = newFix;

      document.getElementById('live-label').textContent='Live';
      document.getElementById('status-chip').style.background='#dcfce7';
      document.getElementById('status-chip').style.color='#15803d';
      document.getElementById('bus-status-text').textContent='Bus is live';
      if (!busMarker) {
        busMarker = L.marker([d.lat,d.lng], {icon:busIcon(true)}).addTo(map);
        map.setView([d.lat,d.lng], 15);
      } else {
        busMarker.setIcon(busIcon(true));
        // Snap to real GPS fix (DR loop will extrapolate from here)
        busMarker.setLatLng([d.lat, d.lng]);
      }
    }).catch(()=>{});
}

function recenterBus() { if(busLat) map.setView([busLat,busLng], 15); }

function toggleSheet() {
  sheetExpanded=!sheetExpanded;
  document.getElementById('bottom-sheet').style.maxHeight=sheetExpanded?'55vh':'110px';
}

var delayDismissed=false;
function pollDelay() {
  fetch(CTX+'/notifications/latest-delay?tripId='+TRIP_ID)
    .then(r=>r.json())
    .then(d=>{
      if (d.hasDelay && !delayDismissed) {
        document.getElementById('delay-banner').classList.add('visible');
        document.getElementById('delay-msg-text').textContent=d.message||'The driver has reported a delay.';
      }
    }).catch(()=>{});
}

window.addEventListener('load', initMap);

// ── AI Chat ──────────────────────────────────────────────────────────────────
let aiOpen = false;
function toggleAiPanel() {
  aiOpen = !aiOpen;
  document.getElementById('ai-panel').classList.toggle('open', aiOpen);
}
function sendAiMsg() {
  const input = document.getElementById('ai-input');
  const msg = input.value.trim();
  if (!msg) return;
  input.value = '';
  appendAiMsg(msg, true);
  const typing = appendTypingIndicator();
  fetch(CTX+'/ai/chat', {
    method:'POST',
    headers:{'Content-Type':'application/x-www-form-urlencoded'},
    body:'tripId='+TRIP_ID+'&message='+encodeURIComponent(msg)
  }).then(r=>r.json()).then(d=>{
    typing.remove();
    appendAiMsg(d.reply || d.error || 'Sorry, no response.', false);
  }).catch(()=>{ typing.remove(); appendAiMsg('Could not reach AI. Check your connection.', false); });
}
function appendAiMsg(text, isUser) {
  const div = document.createElement('div');
  div.className = 'ai-msg ' + (isUser ? 'ai-user' : 'ai-bot');
  div.textContent = text;
  const msgs = document.getElementById('ai-messages');
  msgs.appendChild(div);
  msgs.scrollTop = msgs.scrollHeight;
  return div;
}
function appendTypingIndicator() {
  const div = document.createElement('div');
  div.className = 'ai-msg ai-bot ai-typing';
  div.innerHTML = '<span></span><span></span><span></span>';
  const msgs = document.getElementById('ai-messages');
  msgs.appendChild(div);
  msgs.scrollTop = msgs.scrollHeight;
  return div;
}
// ── AI ETA polling ─────────────────────────────────────────────────────────
function pollAiEta() {
  fetch(CTX+'/ai/eta?tripId='+TRIP_ID)
    .then(r=>r.json())
    .then(d=>{
      document.getElementById('ai-speed-val').textContent =
        d.speedKmh ? parseFloat(d.speedKmh).toFixed(0)+' km/h' : '-- km/h';
      document.getElementById('ai-traffic-val').textContent = d.label || '--';
    }).catch(()=>{});
}
setInterval(pollAiEta, 30000);
pollAiEta();
</script>
</body>
</html>
