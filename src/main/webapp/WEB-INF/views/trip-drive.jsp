<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
  String gaMeasurementId = getServletContext().getInitParameter("ga.measurement.id");
  if (gaMeasurementId == null || "YOUR_GA4_MEASUREMENT_ID".equals(gaMeasurementId))
      gaMeasurementId = System.getenv("GA_MEASUREMENT_ID") != null ? System.getenv("GA_MEASUREMENT_ID") : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<title>CommuteSafe – Drive</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin=""/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
<% if (!gaMeasurementId.isEmpty()) { %>
<script async src="https://www.googletagmanager.com/gtag/js?id=<%= gaMeasurementId %>"></script>
<script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments);}gtag('js',new Date());gtag('config','<%= gaMeasurementId %>');</script>
<% } %>
<style>
  *{box-sizing:border-box;margin:0;padding:0;}
  body{font-family:"Segoe UI",system-ui,sans-serif;height:100dvh;overflow:hidden;background:#e8eaed;}
  #map{position:fixed;inset:0;z-index:0;width:100%;height:100vh;}

  /* Top overlay */
  #topbar{
    position:fixed;top:0;left:0;right:0;z-index:500;
    padding:10px 14px;display:flex;align-items:center;gap:10px;
    background:linear-gradient(180deg,rgba(0,0,0,0.5) 0%,transparent 100%);
    pointer-events:none;
  }
  #topbar>*{pointer-events:all;}
  .back-btn{
    width:40px;height:40px;border-radius:50%;border:none;
    background:white;color:#111;font-size:1rem;flex-shrink:0;
    display:flex;align-items:center;justify-content:center;cursor:pointer;
    box-shadow:0 2px 10px rgba(0,0,0,0.25);
  }
  .route-pill{
    background:white;color:#111;border-radius:20px;
    padding:7px 14px;font-size:0.82rem;font-weight:700;
    box-shadow:0 2px 10px rgba(0,0,0,0.2);
    white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:200px;
  }
  #gps-chip{
    margin-left:auto;border-radius:20px;padding:6px 12px;font-size:0.76rem;
    font-weight:700;display:flex;align-items:center;gap:6px;cursor:pointer;
    background:white;box-shadow:0 2px 10px rgba(0,0,0,0.2);white-space:nowrap;
  }
  #gps-chip.live{color:#16a34a;}
  #gps-chip.off{color:#dc2626;}
  #gps-chip.finding{color:#d97706;}
  .gps-dot{width:7px;height:7px;border-radius:50%;flex-shrink:0;transition:background .2s;}
  .gps-dot.live{background:#16a34a;animation:gpspulse 1.5s infinite;}
  .gps-dot.off{background:#dc2626;}
  .gps-dot.finding{background:#f59e0b;animation:gpspulse .8s infinite;}
  @keyframes gpspulse{0%,100%{opacity:1}50%{opacity:.35}}

  /* Turn instruction card */
  #nav-card{
    position:fixed;top:68px;left:14px;right:14px;z-index:490;
    background:white;border-radius:20px;
    box-shadow:0 4px 24px rgba(0,0,0,0.15);
    padding:14px 16px;display:flex;align-items:center;gap:14px;
    transition:transform .25s,opacity .25s;
  }
  #nav-card.hidden{opacity:0;transform:translateY(-8px);pointer-events:none;}
  .turn-arrow{
    width:54px;height:54px;border-radius:15px;background:#f0fdf4;
    display:flex;align-items:center;justify-content:center;
    font-size:1.65rem;flex-shrink:0;color:#16a34a;
  }
  #nav-dist-row{display:flex;align-items:baseline;gap:3px;}
  #nav-dist{font-size:1.6rem;font-weight:900;color:#111;line-height:1;}
  #nav-unit{font-size:.72rem;font-weight:700;color:#9ca3af;}
  #nav-step{font-size:.86rem;color:#374151;margin-top:3px;line-height:1.4;}

  /* GPS blocked card */
  #gps-error-card{
    position:fixed;top:68px;left:14px;right:14px;z-index:491;
    background:white;border-radius:20px;
    box-shadow:0 4px 24px rgba(0,0,0,0.15);
    padding:14px 16px;display:none;align-items:center;gap:12px;
  }
  #gps-error-card.visible{display:flex;}

  /* AI risk banner */
  #ai-risk-banner{
    position:fixed;z-index:488;left:14px;right:14px;
    border-radius:14px;padding:11px 14px;
    display:none;align-items:center;gap:10px;font-size:.82rem;
  }
  #ai-risk-banner.visible{display:flex;}
  #ai-risk-banner.risk-HIGH{
    background:rgba(254,242,242,.96);border:1.5px solid #fca5a5;color:#991b1b;
  }
  #ai-risk-banner.risk-MEDIUM{
    background:rgba(255,251,235,.96);border:1.5px solid #fcd34d;color:#92400e;
  }

  /* Map controls */
  #map-controls{
    position:fixed;right:14px;top:50%;transform:translateY(-50%);
    z-index:400;display:flex;flex-direction:column;gap:8px;
  }
  .map-btn{
    width:44px;height:44px;border-radius:12px;border:none;
    background:white;color:#111;font-size:1.1rem;
    display:flex;align-items:center;justify-content:center;cursor:pointer;
    box-shadow:0 2px 10px rgba(0,0,0,0.15);
  }
  .map-btn:hover{background:#f9fafb;}

  /* Speed badge */
  #speed-badge{
    position:fixed;left:16px;z-index:490;
    width:64px;height:64px;border-radius:50%;
    background:white;border:3px solid #e5e7eb;
    display:flex;flex-direction:column;align-items:center;justify-content:center;
    box-shadow:0 2px 10px rgba(0,0,0,0.15);
    transition:bottom .35s cubic-bezier(.32,.72,0,1),border-color .2s;
  }
  #speed-badge.speeding{border-color:#ef4444;background:#fef2f2;}
  #speed-val{font-size:1.25rem;font-weight:900;color:#111;line-height:1;}
  #speed-unit{font-size:.55rem;color:#9ca3af;font-weight:700;text-transform:uppercase;margin-top:1px;}

  /* Bottom sheet */
  #bottom-sheet{
    position:fixed;bottom:0;left:0;right:0;z-index:500;
    background:white;border-radius:24px 24px 0 0;
    box-shadow:0 -4px 32px rgba(0,0,0,0.13);
    height:48vh;overflow:hidden;display:flex;flex-direction:column;
    transition:height .35s cubic-bezier(.32,.72,0,1);
  }
  #sheet-handle{
    flex-shrink:0;padding:12px 0 8px;display:flex;justify-content:center;
    cursor:grab;touch-action:none;
  }
  #sheet-handle:active{cursor:grabbing;}
  .handle-bar{width:44px;height:4px;border-radius:2px;background:#e5e7eb;}
  #sheet-inner{overflow-y:auto;flex:1;padding:0 16px 36px;}

  /* Status row */
  #trip-header{
    display:flex;align-items:center;gap:8px;
    padding-bottom:14px;border-bottom:1px solid #f3f4f6;margin-bottom:14px;
  }
  .status-dot{width:9px;height:9px;border-radius:50%;flex-shrink:0;}
  #trip-status-lbl{font-size:.74rem;font-weight:700;text-transform:uppercase;letter-spacing:.05em;}
  #trip-route-lbl{
    margin-left:auto;font-size:.73rem;color:#9ca3af;font-weight:600;
    white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:160px;
  }

  /* Action buttons */
  #action-row{display:flex;gap:10px;margin-bottom:14px;}
  .action-btn{
    border-radius:14px;border:none;cursor:pointer;
    font-size:.88rem;font-weight:700;padding:14px 12px;
    display:flex;align-items:center;justify-content:center;gap:7px;
    transition:opacity .15s,transform .1s;
  }
  .action-btn:not(:disabled):active{transform:scale(.97);}
  .action-btn:not(:disabled):hover{opacity:.9;}
  .btn-start   {flex:1;background:#16a34a;color:white;}
  .btn-complete{flex:1;background:#2563eb;color:white;}
  .btn-delay   {flex:0 0 auto;padding:14px 18px;background:#f9fafb;color:#374151;border:1.5px solid #e5e7eb;}
  .btn-done    {flex:1;background:#f3f4f6;color:#9ca3af;cursor:not-allowed;}

  /* Destination card */
  #dest-card{
    background:#f8fafc;border-radius:14px;padding:13px 14px;
    display:flex;align-items:center;gap:12px;
    border:1.5px solid #e5e7eb;margin-bottom:14px;
  }
  .dest-icon{
    width:40px;height:40px;border-radius:50%;background:#dbeafe;
    color:#2563eb;font-size:1rem;
    display:flex;align-items:center;justify-content:center;flex-shrink:0;
  }
  #dest-name{font-weight:700;font-size:.92rem;color:#111;}
  #dest-sub{font-size:.75rem;color:#6b7280;margin-top:2px;}

  /* Route timeline */
  .section-lbl{
    font-size:.7rem;font-weight:700;color:#9ca3af;
    text-transform:uppercase;letter-spacing:.07em;margin-bottom:10px;
  }
  .tl-item{display:flex;align-items:center;gap:10px;padding:8px 0;}
  .tl-item+.tl-item{border-top:1px solid #f3f4f6;}
  .tl-dot{width:10px;height:10px;border-radius:50%;background:#d1d5db;flex-shrink:0;}
  .tl-dot.done{background:#16a34a;}
  .tl-dot.active{background:#16a34a;box-shadow:0 0 0 4px rgba(22,163,74,.15);}
  .tl-name{font-size:.85rem;color:#6b7280;}
  .tl-name.active{color:#111;font-weight:600;}

  /* Delay modal */
  #delay-modal{
    display:none;position:fixed;inset:0;z-index:600;
    background:rgba(0,0,0,.5);backdrop-filter:blur(4px);
    align-items:flex-end;justify-content:center;
  }
  #delay-modal.open{display:flex;}
  .modal-sheet{
    background:white;border-radius:24px 24px 0 0;
    width:100%;max-width:520px;padding:20px 20px 36px;
  }
  .modal-handle-row{display:flex;justify-content:center;margin-bottom:18px;}
  .modal-handle{width:44px;height:4px;border-radius:2px;background:#e5e7eb;}
  .modal-title{font-size:1rem;font-weight:700;color:#111;margin-bottom:3px;}
  .modal-sub{font-size:.8rem;color:#9ca3af;margin-bottom:14px;}
  .modal-sheet textarea{
    width:100%;background:#f9fafb;color:#111;
    border:1.5px solid #e5e7eb;border-radius:12px;
    padding:12px 14px;font-size:.88rem;resize:none;
    font-family:inherit;outline:none;transition:border-color .2s;
  }
  .modal-sheet textarea:focus{border-color:#16a34a;}
  .modal-btns{display:flex;gap:10px;margin-top:12px;}
  .modal-cancel{
    flex:0 0 auto;padding:12px 20px;border-radius:12px;
    border:1.5px solid #e5e7eb;background:white;
    color:#374151;font-weight:700;cursor:pointer;font-family:inherit;
  }
  .modal-cancel:hover{background:#f9fafb;}
  .modal-send{
    flex:1;padding:12px;border-radius:12px;border:none;
    background:#d97706;color:white;font-weight:700;cursor:pointer;font-family:inherit;
  }
  .modal-send:hover{background:#b45309;}
</style>
</head>
<body>

<div id="map"></div>

<!-- Top bar -->
<div id="topbar">
  <button class="back-btn" onclick="history.back()" aria-label="Back">
    <i class="bi bi-arrow-left"></i>
  </button>
  <div class="route-pill">
    <i class="bi bi-bus-front-fill" style="color:#16a34a;margin-right:4px;"></i>${trip.route.routeName}
  </div>
  <div id="gps-chip" class="off" onclick="retryGps()" title="Tap to retry GPS">
    <div class="gps-dot off" id="gps-dot"></div>
    <span id="gps-label">GPS Off</span>
  </div>
</div>

<!-- Turn-by-turn card -->
<div id="nav-card">
  <div class="turn-arrow"><i class="bi bi-arrow-up-circle-fill" id="turn-icon-i"></i></div>
  <div style="flex:1;min-width:0;">
    <div id="nav-dist-row">
      <span id="nav-dist">–</span>
      <span id="nav-unit"></span>
    </div>
    <div id="nav-step">Starting navigation…</div>
  </div>
</div>

<!-- GPS blocked card -->
<div id="gps-error-card">
  <div style="width:40px;height:40px;border-radius:12px;background:#fee2e2;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
    <i class="bi bi-geo-slash-fill" style="color:#dc2626;font-size:1.1rem;"></i>
  </div>
  <div style="flex:1;">
    <div style="font-size:.84rem;font-weight:700;color:#111;">Location access blocked</div>
    <div style="font-size:.75rem;color:#6b7280;margin-top:2px;">Enable GPS in browser settings, then tap <b>GPS Off</b> above to retry.</div>
  </div>
  <button onclick="retryGps()" style="background:#dc2626;color:white;border:none;border-radius:10px;padding:8px 14px;font-size:.8rem;font-weight:700;cursor:pointer;flex-shrink:0;">Retry</button>
</div>

<!-- AI risk banner (sits just below nav card dynamically) -->
<div id="ai-risk-banner" style="top:160px;">
  <i class="bi bi-exclamation-triangle-fill" style="flex-shrink:0;font-size:1.1rem;"></i>
  <div style="flex:1;">
    <div id="ai-risk-msg" style="font-weight:700;">Analysing route…</div>
    <div id="ai-risk-conf" style="font-size:.72rem;opacity:.8;margin-top:1px;">AI delay prediction</div>
  </div>
  <button onclick="document.getElementById('ai-risk-banner').classList.remove('visible')"
    style="background:none;border:none;cursor:pointer;color:inherit;font-size:1rem;padding:0 0 0 6px;">✕</button>
</div>

<!-- Map controls -->
<div id="map-controls">
  <button class="map-btn" onclick="map&&map.setZoom(map.getZoom()+1)" aria-label="Zoom in"><i class="bi bi-plus-lg"></i></button>
  <button class="map-btn" onclick="map&&map.setZoom(map.getZoom()-1)" aria-label="Zoom out"><i class="bi bi-dash-lg"></i></button>
  <button class="map-btn" onclick="recenterMap()" aria-label="Re-centre"><i class="bi bi-crosshair2"></i></button>
</div>

<!-- Speed badge -->
<div id="speed-badge" style="bottom:49vh;">
  <span id="speed-val">–</span>
  <span id="speed-unit">km/h</span>
</div>

<!-- Bottom sheet -->
<div id="bottom-sheet">
  <div id="sheet-handle"><div class="handle-bar"></div></div>
  <div id="sheet-inner">

    <!-- Status row -->
    <div id="trip-header">
      <div class="status-dot" id="trip-status-dot" style="background:#f59e0b;"></div>
      <span id="trip-status-lbl" style="color:#92400e;">
        <c:choose>
          <c:when test="${trip.status == 'SCHEDULED'}">Scheduled</c:when>
          <c:when test="${trip.status == 'IN_PROGRESS'}">In Progress</c:when>
          <c:when test="${trip.status == 'COMPLETED'}">Completed</c:when>
          <c:otherwise>${trip.status}</c:otherwise>
        </c:choose>
      </span>
      <span id="trip-route-lbl">${trip.route.startLocation} → ${trip.route.endLocation}</span>
    </div>

    <!-- Action buttons -->
    <div id="action-row">
      <c:choose>
        <c:when test="${trip.status == 'SCHEDULED'}">
          <button class="action-btn btn-start" onclick="updateStatus('IN_PROGRESS')">
            <i class="bi bi-play-fill"></i> Start Trip
          </button>
        </c:when>
        <c:when test="${trip.status == 'IN_PROGRESS'}">
          <button class="action-btn btn-complete" onclick="updateStatus('COMPLETED')">
            <i class="bi bi-flag-fill"></i> Complete Trip
          </button>
          <button class="action-btn btn-delay" onclick="openDelay()">
            <i class="bi bi-clock-history"></i> Delay
          </button>
        </c:when>
        <c:otherwise>
          <button class="action-btn btn-done" disabled>
            <i class="bi bi-check-circle-fill"></i>
            <c:choose>
              <c:when test="${trip.status == 'COMPLETED'}">Trip Completed</c:when>
              <c:otherwise>${trip.status}</c:otherwise>
            </c:choose>
          </button>
        </c:otherwise>
      </c:choose>
    </div>

    <!-- Destination card -->
    <div id="dest-card">
      <div class="dest-icon"><i class="bi bi-geo-alt-fill"></i></div>
      <div>
        <div id="dest-name">${trip.route.endLocation}</div>
        <div id="dest-sub">Destination · Calculating route…</div>
      </div>
    </div>

    <!-- Route timeline -->
    <div class="section-lbl">Route</div>
    <div id="route-timeline">
      <div class="tl-item">
        <div class="tl-dot done"></div>
        <span class="tl-name">${trip.route.startLocation}</span>
      </div>
      <div class="tl-item">
        <div class="tl-dot active"></div>
        <span class="tl-name active">${trip.route.endLocation}</span>
      </div>
    </div>

  </div>
</div>

<!-- Delay modal -->
<div id="delay-modal">
  <div class="modal-sheet">
    <div class="modal-handle-row"><div class="modal-handle"></div></div>
    <div class="modal-title"><i class="bi bi-clock-history" style="color:#d97706;margin-right:6px;"></i>Report Delay</div>
    <div class="modal-sub">Passengers on this trip will be notified immediately.</div>
    <textarea id="delay-msg" rows="3" placeholder="Describe the reason for the delay…"></textarea>
    <div class="modal-btns">
      <button class="modal-cancel" onclick="closeDelay()">Cancel</button>
      <button class="modal-send" onclick="sendDelay()">
        <i class="bi bi-send-fill" style="margin-right:5px;"></i>Send Alert
      </button>
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
const START_LOCATION  = '${trip.route.startLocation}';

let map, busMarker, routePolyline, historyPolyline;
let lastLat = null, lastLng = null, lastFix = null;
let watchId = null;
let steps = [], stepIdx = 0;
let sheetState = 'partial';
let userPanned = false;
let _lastPosTs = null;

/* ─── Draggable bottom sheet ──────────────────────────────────────────────── */
(function() {
  const sheet  = document.getElementById('bottom-sheet');
  const handle = document.getElementById('sheet-handle');
  const badge  = document.getElementById('speed-badge');
  const HEIGHTS = { collapsed:'72px', partial:'48vh', expanded:'86vh' };

  function applyState(s) {
    sheetState = s;
    sheet.style.transition = 'height .35s cubic-bezier(.32,.72,0,1)';
    sheet.style.height = HEIGHTS[s];
    badge.style.transition = 'bottom .35s cubic-bezier(.32,.72,0,1)';
    badge.style.bottom = 'calc(' + HEIGHTS[s] + ' + 14px)';
  }

  let startY = 0, startH = 0, dragging = false, movedPx = 0;
  function onStart(e) {
    dragging = true; movedPx = 0;
    startY = e.touches ? e.touches[0].clientY : e.clientY;
    startH = sheet.getBoundingClientRect().height;
    sheet.style.transition = 'none';
  }
  function onMove(e) {
    if (!dragging) return;
    if (e.cancelable) e.preventDefault();
    const y = e.touches ? e.touches[0].clientY : e.clientY;
    const diff = startY - y;
    movedPx = Math.abs(diff);
    sheet.style.height = Math.max(52, Math.min(window.innerHeight * .92, startH + diff)) + 'px';
  }
  function onEnd() {
    if (!dragging) return;
    dragging = false;
    if (movedPx > 8) {
      const h = sheet.getBoundingClientRect().height, vh = window.innerHeight;
      applyState(h < vh * .18 ? 'collapsed' : h > vh * .60 ? 'expanded' : 'partial');
    } else {
      applyState(sheetState === 'collapsed' ? 'partial' : sheetState === 'partial' ? 'expanded' : 'partial');
    }
  }
  handle.addEventListener('touchstart',  onStart, { passive: true });
  handle.addEventListener('touchmove',   onMove,  { passive: false });
  handle.addEventListener('touchend',    onEnd);
  handle.addEventListener('mousedown',   onStart);
  document.addEventListener('mousemove', onMove);
  document.addEventListener('mouseup',   onEnd);
  applyState('partial');
})();

/* ─── GPS UI ──────────────────────────────────────────────────────────────── */
function setGpsState(s) {
  ['live','off','finding'].forEach(c => {
    document.getElementById('gps-chip').classList.toggle(c, c === s);
    document.getElementById('gps-dot').classList.toggle(c, c === s);
  });
  document.getElementById('gps-label').textContent = { live:'Live', off:'GPS Off', finding:'Finding…' }[s] || s;
}

/* ─── Map helpers ─────────────────────────────────────────────────────────── */
function makeBusIcon() {
  const bg = '#16a34a';
  const busSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 17" width="28" height="20">'
    + '<rect x="1" y="1" width="22" height="12" rx="2" fill="white" opacity="0.95"/>'
    + '<rect x="2" y="2" width="4" height="5" rx="0.8" fill="' + bg + '" opacity="0.75"/>'
    + '<rect x="8" y="2" width="4" height="5" rx="0.8" fill="' + bg + '" opacity="0.75"/>'
    + '<rect x="14" y="2" width="4" height="5" rx="0.8" fill="' + bg + '" opacity="0.75"/>'
    + '<rect x="20" y="2" width="3" height="5" rx="0.8" fill="' + bg + '" opacity="0.5"/>'
    + '<circle cx="5.5" cy="16" r="2.2" fill="white" opacity="0.9"/>'
    + '<circle cx="18.5" cy="16" r="2.2" fill="white" opacity="0.9"/>'
    + '</svg>';
  const html = '<div style="width:48px;height:36px;border-radius:10px;background:' + bg
    + ';box-shadow:0 3px 14px rgba(22,163,74,0.5),0 0 0 2.5px white;display:flex;align-items:center;justify-content:center;">'
    + busSvg + '</div>';
  return L.divIcon({className: '', html: html, iconSize: [48, 36], iconAnchor: [24, 18]});
}
function makeDotIcon(color) {
  return L.divIcon({
    className: '',
    html: '<div style="width:14px;height:14px;border-radius:50%;background:' + color + ';border:2.5px solid white;box-shadow:0 1px 3px rgba(0,0,0,0.3)"></div>',
    iconSize: [14, 14],
    iconAnchor: [7, 7]
  });
}
function calcHeading(from, to) {
  const r = d => d * Math.PI / 180, dL = r(to.lng - from.lng);
  const y = Math.sin(dL) * Math.cos(r(to.lat));
  const x = Math.cos(r(from.lat)) * Math.sin(r(to.lat)) - Math.sin(r(from.lat)) * Math.cos(r(to.lat)) * Math.cos(dL);
  return (Math.atan2(y, x) * 180 / Math.PI + 360) % 360;
}
function haversineKm(lat1, lng1, lat2, lng2) {
  const R = 6371, r = x => x * Math.PI / 180;
  const dLat = r(lat2 - lat1), dLng = r(lng2 - lng1);
  const a = Math.sin(dLat/2)**2 + Math.cos(r(lat1)) * Math.cos(r(lat2)) * Math.sin(dLng/2)**2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

/* ─── Map init ────────────────────────────────────────────────────────────── */
function initMap() {
  const center = (ROUTE_START_LAT && ROUTE_START_LNG)
    ? [ROUTE_START_LAT, ROUTE_START_LNG]
    : [-25.7313, 28.1648];

  map = L.map('map', { center: center, zoom: 15, zoomControl: false });
  L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
    attribution: '&copy; <a href="https://carto.com/attributions">CARTO</a>',
    maxZoom: 20, subdomains: 'abcd'
  }).addTo(map);
  map.on('dragstart', () => { userPanned = true; });

  if (ROUTE_START_LAT && ROUTE_START_LNG)
    L.marker([ROUTE_START_LAT, ROUTE_START_LNG], {icon: makeDotIcon('#16a34a')}).addTo(map);
  if (ROUTE_END_LAT && ROUTE_END_LNG)
    L.marker([ROUTE_END_LAT, ROUTE_END_LNG], {icon: makeDotIcon('#ef4444')}).addTo(map);

  if (ROUTE_START_LAT && ROUTE_END_LAT) {
    routePolyline = L.polyline(
      [[ROUTE_START_LAT, ROUTE_START_LNG], [ROUTE_END_LAT, ROUTE_END_LNG]],
      {color: '#93c5fd', opacity: 0.7, weight: 4}
    ).addTo(map);
    map.fitBounds(
      L.latLngBounds([ROUTE_START_LAT, ROUTE_START_LNG], [ROUTE_END_LAT, ROUTE_END_LNG]),
      {paddingTopLeft: [70, 80], paddingBottomRight: [70, 220]}
    );
  }
  loadRouteHistory();
}
window.addEventListener('DOMContentLoaded', initMap);

function loadRouteHistory() {
  fetch(CTX + '/tracking/history?tripId=' + TRIP_ID)
    .then(r => r.json())
    .then(pts => {
      if (pts.length) {
        if (historyPolyline) { historyPolyline.remove(); historyPolyline = null; }
        historyPolyline = L.polyline(pts, {color: '#16a34a', opacity: 0.5, weight: 3}).addTo(map);
      }
      startTracking();
    }).catch(() => startTracking());
}

/* ─── GPS tracking ────────────────────────────────────────────────────────── */
function startTracking() {
  if (!navigator.geolocation) { onGpsError({ code: -1 }); return; }
  watchId = navigator.geolocation.watchPosition(onPos, onGpsError,
    { enableHighAccuracy: true, maximumAge: 2000, timeout: 15000 });
}

function onGpsError(err) {
  setGpsState('off');
  if (err && err.code === 1)
    document.getElementById('gps-error-card').classList.add('visible');
}

function retryGps() {
  if (watchId != null) { navigator.geolocation.clearWatch(watchId); watchId = null; }
  document.getElementById('gps-error-card').classList.remove('visible');
  setGpsState('finding');
  startTracking();
}

function onPos(pos) {
  setGpsState('live');
  document.getElementById('gps-error-card').classList.remove('visible');
  const { latitude: lat, longitude: lng, speed } = pos.coords;
  const now = Date.now();

  // Speed calculation
  let kmh = 0;
  if (speed != null && speed >= 0) {
    kmh = speed * 3.6;
  } else if (_lastPosTs && lastFix) {
    const dtS = (now - _lastPosTs) / 1000;
    const dm  = haversineKm(lastFix.lat, lastFix.lng, lat, lng) * 1000;
    kmh = dtS > 0 ? (dm / dtS) * 3.6 : 0;
  }
  _lastPosTs = now;
  const sv = document.getElementById('speed-val');
  sv.textContent = kmh > 1 ? Math.round(kmh) : '–';
  document.getElementById('speed-badge').classList.toggle('speeding', kmh > 80);

  if (lastFix) calcHeading(lastFix, { lat, lng });
  lastFix = { lat, lng };
  lastLat = lat; lastLng = lng;

  if (!busMarker) {
    busMarker = L.marker([lat, lng], {icon: makeBusIcon(), zIndexOffset: 1000}).addTo(map);
    map.setView([lat, lng], 18);
    buildRoute(lat, lng);
  } else {
    busMarker.setLatLng([lat, lng]);
    if (!userPanned) map.panTo([lat, lng]);
    advanceStep(lat, lng);
  }
  sendGps(lat, lng);

  if (!window._lastSafe || (now - window._lastSafe) > 30000) {
    window._lastSafe = now;
    checkSafeRoute(lat, lng);
  }
}

/* ─── Directions ──────────────────────────────────────────────────────────── */
function buildRoute(lat, lng) {
  if (!ROUTE_END_LAT || !ROUTE_END_LNG) return;
  const url = 'https://router.project-osrm.org/route/v1/driving/'
    + lng + ',' + lat + ';' + ROUTE_END_LNG + ',' + ROUTE_END_LAT
    + '?steps=true&geometries=geojson&overview=full';
  fetch(url)
    .then(r => r.json())
    .then(data => {
      if (!data.routes || !data.routes.length) return;
      const route = data.routes[0];
      const coords = route.geometry.coordinates.map(c => [c[1], c[0]]);
      if (routePolyline) { routePolyline.remove(); routePolyline = null; }
      routePolyline = L.polyline(coords, {color: '#16a34a', opacity: 0.9, weight: 6}).addTo(map);
      const leg = route.legs[0];
      const distText = leg.distance >= 1000
        ? (leg.distance / 1000).toFixed(1) + ' km'
        : Math.round(leg.distance) + ' m';
      const durText = Math.round(leg.duration / 60) + ' min';
      document.getElementById('dest-sub').textContent = 'Destination \u00b7 ' + durText + ' \u00b7 ' + distText;
      steps = [];
      (leg.steps || []).forEach(s => {
        steps.push({ instruction: getStepInstruction(s), distM: s.distance || 0 });
      });
      stepIdx = 0;
      if (steps.length) showStep(steps[0]);
    }).catch(() => {});
}
function getStepInstruction(step) {
  const mod  = step.maneuver.modifier || '';
  const name = step.name ? ' onto ' + step.name : '';
  switch (step.maneuver.type) {
    case 'depart':          return 'Head ' + (mod ? mod + ' ' : '') + (step.name ? 'on ' + step.name : 'forward');
    case 'arrive':          return 'You have arrived';
    case 'turn':            return 'Turn ' + mod + name;
    case 'continue':        return 'Continue' + name;
    case 'merge':           return 'Merge' + name;
    case 'roundabout':      return 'Enter the roundabout';
    case 'exit roundabout': return 'Exit the roundabout' + name;
    default:                return 'Continue' + name;
  }
}

function showStep(s) {
  if (!s) return;
  const m = s.distM;
  document.getElementById('nav-dist').textContent = m >= 1000 ? (m/1000).toFixed(1) : m.toString();
  document.getElementById('nav-unit').textContent = m >= 1000 ? ' km' : ' m';
  document.getElementById('nav-step').textContent = s.instruction;
}

function advanceStep(lat, lng) {
  if (!steps.length || stepIdx >= steps.length) return;
  const s = steps[stepIdx];
  showStep(s);
  if (s.distM < 40 && stepIdx < steps.length - 1) stepIdx++;
  else if (s.distM > 0) steps[stepIdx].distM = Math.max(0, s.distM - 18);
}

function recenterMap() {
  if (lastLat) { userPanned = false; map.setView([lastLat, lastLng], 18); }
}

/* ─── AI Risk ─────────────────────────────────────────────────────────────── */
function checkSafeRoute(lat, lng) {
  fetch(CTX + '/ai/safe-route?tripId=' + TRIP_ID + '&lat=' + lat + '&lng=' + lng)
    .then(r => r.json())
    .then(d => {
      const banner = document.getElementById('ai-risk-banner');
      if (!d.status || d.status === 'SAFE') { banner.classList.remove('visible'); return; }
      banner.className = 'visible risk-' + (d.status === 'ALERT' ? 'HIGH' : 'MEDIUM');
      document.getElementById('ai-risk-msg').textContent  = d.message || 'Route anomaly detected';
      document.getElementById('ai-risk-conf').textContent = 'Deviation: ' + (d.deviationM||0).toFixed(0) + 'm · AI safe-route';
    }).catch(() => {});
}

function pollDelayRisk() {
  fetch(CTX + '/ai/delay-risk?tripId=' + TRIP_ID)
    .then(r => r.json())
    .then(d => {
      const banner = document.getElementById('ai-risk-banner');
      if (!d.risk || d.risk === 'LOW') { banner.classList.remove('visible'); return; }
      banner.className = 'visible risk-' + d.risk;
      document.getElementById('ai-risk-msg').textContent =
        d.risk === 'HIGH' ? 'High delay risk on this segment' : 'Moderate slowdown ahead';
      document.getElementById('ai-risk-conf').textContent =
        (d.confidence || '--') + ' confidence · AI prediction';
    }).catch(() => {});
}
setInterval(pollDelayRisk, 30000);
setTimeout(pollDelayRisk, 5000);

/* ─── Trip status update ──────────────────────────────────────────────────── */
function _doUpdate(status) {
  fetch(CTX + '/trips/update-status', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'tripId=' + TRIP_ID + '&status=' + status
  }).then(r => r.json()).then(d => {
    if (d.error) { alert(d.error); return; }
    location.reload();
  }).catch(() => location.reload());
}

function updateStatus(status) {
  if (status === 'IN_PROGRESS' && ROUTE_START_LAT && ROUTE_START_LNG) {
    navigator.geolocation.getCurrentPosition(
      function(pos) {
        const d = haversineKm(pos.coords.latitude, pos.coords.longitude, ROUTE_START_LAT, ROUTE_START_LNG);
        if (d > 0.5) {
          alert('You are ' + d.toFixed(2) + ' km from the start.\nPlease be within 0.5 km of ' + START_LOCATION + ' to start the trip.');
          return;
        }
        _doUpdate(status);
      },
      () => _doUpdate(status),
      { enableHighAccuracy: true, timeout: 8000, maximumAge: 0 }
    );
  } else {
    _doUpdate(status);
  }
}

/* ─── Delay modal ─────────────────────────────────────────────────────────── */
function openDelay()  { document.getElementById('delay-modal').classList.add('open');    }
function closeDelay() { document.getElementById('delay-modal').classList.remove('open'); }
document.getElementById('delay-modal').addEventListener('click', function(e) {
  if (e.target === this) closeDelay();
});

function sendDelay() {
  const msg = document.getElementById('delay-msg').value.trim();
  if (!msg) return;
  fetch(CTX + '/notifications/delay', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'tripId=' + TRIP_ID + '&message=' + encodeURIComponent(msg)
  }).then(() => {
    closeDelay();
    document.getElementById('delay-msg').value = '';
  }).catch(() => {});
}

/* ─── Send GPS to server ──────────────────────────────────────────────────── */
function sendGps(lat, lng) {
  fetch(CTX + '/tracking/update', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'tripId=' + TRIP_ID + '&lat=' + lat + '&lng=' + lng
  }).catch(() => {});
}
</script>
</body>
</html>
