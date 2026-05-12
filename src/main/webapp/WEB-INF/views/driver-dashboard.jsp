<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>CommuteSafe Driver</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        html, body { height: 100%; overflow: hidden; font-family: "Segoe UI", sans-serif; }
        #map { position: fixed; inset: 0; width: 100%; height: 100%; z-index: 1; }
        .topbar { position: fixed; top: 0; left: 0; right: 0; z-index: 100; display: flex; align-items: center; padding: 12px 16px; gap: 10px; pointer-events: none; }
        .topbar > * { pointer-events: all; }
        .menu-btn { width: 44px; height: 44px; background: #fff; border-radius: 50%; border: none; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 1.15rem; box-shadow: 0 2px 14px rgba(0,0,0,0.22); transition: background .2s; }
        .menu-btn:hover { background: #f0f0f0; }
        .driver-pill { background: #1a1a1a; color: #fff; padding: 8px 16px; border-radius: 24px; font-size: 0.82rem; font-weight: 700; display: flex; align-items: center; gap: 8px; box-shadow: 0 2px 14px rgba(0,0,0,0.25); margin-left: auto; }
        .driver-pill .dot { width: 8px; height: 8px; background: #00c853; border-radius: 50%; animation: pulse 1.4s infinite; }
        @keyframes pulse { 0%,100%{box-shadow:0 0 0 0 rgba(0,200,83,.5)} 50%{box-shadow:0 0 0 7px rgba(0,200,83,0)} }
        .logout-btn { width: 44px; height: 44px; background: #fff; border-radius: 50%; border: none; display: flex; align-items: center; justify-content: center; font-size: 1.1rem; color: #555; cursor: pointer; box-shadow: 0 2px 14px rgba(0,0,0,0.22); text-decoration: none; transition: background .2s; }
        .logout-btn:hover { background: #fff1f2; color: #dc2626; }
        .bottom-sheet { position: fixed; bottom: 0; left: 0; right: 0; z-index: 100; background: #fff; border-radius: 24px 24px 0 0; box-shadow: 0 -4px 32px rgba(0,0,0,0.18); height: 58vh; overflow-y: auto; transition: height .35s cubic-bezier(.32,.72,0,1); }
        .bottom-sheet.collapsed { height: 52px; overflow: hidden; }
        .sheet-handle { display: flex; flex-direction: column; align-items: center; padding: 10px 0 6px; gap: 5px; cursor: grab; touch-action: none; }
        .sheet-bar { width: 40px; height: 4px; background: #4b5563; border-radius: 4px; }
        .sheet-hint { font-size: .6rem; color: #475569; font-weight: 700; letter-spacing: .5px; }
        .sheet-content { padding: 4px 18px 32px; }
        .stats-bar { display: flex; gap: 10px; margin-bottom: 18px; }
        .stat-chip { flex: 1; background: #f7f8fa; border-radius: 14px; padding: 12px 8px; text-align: center; }
        .stat-num { font-size: 1.7rem; font-weight: 800; color: #1a1a1a; line-height: 1; }
        .stat-num.green { color: #00c853; }
        .stat-num.purple { color: #6366f1; }
        .stat-lbl { font-size: 0.67rem; text-transform: uppercase; letter-spacing: .8px; color: #999; margin-top: 3px; }
        .section-lbl { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 1.2px; color: #aaa; margin-bottom: 10px; font-weight: 700; }
        .trip-card { border-radius: 16px; padding: 16px; margin-bottom: 12px; border: 1.5px solid #f0f0f0; background: #fff; transition: box-shadow .2s; }
        .trip-card:hover { box-shadow: 0 4px 18px rgba(0,0,0,.08); }
        .trip-card.live { border-color: #00c853; background: #f0fff4; }
        .trip-card.scheduled { border-color: #6366f1; background: #f5f3ff; }
        .trip-card.done { opacity: .55; }
        .card-top { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
        .card-icon { width: 46px; height: 46px; border-radius: 14px; font-size: 1.4rem; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .card-icon.live { background: #dcfce7; }
        .card-icon.scheduled { background: #ede9fe; }
        .card-icon.done { background: #f3f4f6; }
        .card-title { font-weight: 700; font-size: 1rem; color: #111; }
        .card-sub { font-size: 0.78rem; color: #888; margin-top: 2px; }
        .card-badge { margin-left: auto; font-size: .68rem; font-weight: 800; padding: 4px 10px; border-radius: 20px; text-transform: uppercase; white-space: nowrap; }
        .card-badge.live { background: #dcfce7; color: #16a34a; }
        .card-badge.scheduled { background: #ede9fe; color: #7c3aed; }
        .card-badge.done { background: #f3f4f6; color: #6b7280; }
        .card-actions { display: flex; gap: 8px; flex-wrap: wrap; }
        .btn-action { flex: 1; min-width: 110px; padding: 11px 12px; border-radius: 12px; font-size: .85rem; font-weight: 700; border: none; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 6px; text-decoration: none; transition: all .15s; }
        .btn-go { background: #1a1a1a; color: #fff; }
        .btn-go:hover:not(:disabled) { background: #00c853; color: #000; }
        .btn-go:disabled { background: #f1f5f9; color: #94a3b8; cursor: not-allowed; border: 1.5px solid #e2e8f0; }
        .btn-go.window-passed:disabled { background: #fff1f2; color: #dc2626; border-color: #fecaca; }
        .btn-map { background: #f0fff4; color: #16a34a; border: 1.5px solid #bbf7d0; }
        .btn-map:hover { background: #dcfce7; }
        .btn-delay { background: #fffbeb; color: #d97706; border: 1.5px solid #fde68a; }
        .btn-delay:hover { background: #fef3c7; }
        .btn-end { background: #fff1f2; color: #dc2626; border: 1.5px solid #fecaca; }
        .btn-end:hover { background: #fee2e2; }
        .empty-state { text-align: center; padding: 36px 16px; color: #bbb; }
        .empty-state i { font-size: 2.8rem; display: block; margin-bottom: 10px; }
        #dd-overlay { display:none; position:fixed; inset:0; background:rgba(0,0,0,.55); z-index:9999; align-items:flex-end; justify-content:center; }
        #dd-overlay.open { display:flex; }
        #dd-modal { background:#fff; border-radius:24px 24px 0 0; padding:24px 20px 36px; width:100%; max-width:540px; }
        #dd-modal h5 { font-weight:800; color:#d97706; margin-bottom:6px; }
        #dd-modal p { font-size:.82rem; color:#888; margin-bottom:14px; }
        .dd-reason { display:block; width:100%; text-align:left; padding:11px 16px; margin-bottom:8px; border-radius:12px; border:1.5px solid #f0f0f0; background:#fff; color:#444; cursor:pointer; font-size:.875rem; font-weight:600; transition:all .15s; }
        .dd-reason:hover,.dd-reason.selected { border-color:#f59e0b; color:#d97706; background:#fffbeb; }
        #dd-custom { width:100%; margin-top:4px; border-radius:10px; border:1.5px solid #e0e0e0; padding:10px 14px; font-size:.875rem; }
        #dd-custom:focus { outline:none; border-color:#f59e0b; }
        #dd-submit { background:#1a1a1a; color:#fff; border:none; border-radius:14px; padding:14px 0; width:100%; font-weight:800; cursor:pointer; margin-top:12px; }
        #dd-submit:hover { background:#00c853; color:#000; }
        #dd-cancel { background:transparent; border:none; color:#aaa; width:100%; padding:8px; cursor:pointer; font-size:.85rem; margin-top:4px; }
        #dd-done { display:none; text-align:center; padding:16px 0 8px; color:#16a34a; font-weight:700; }
        /* Schedule banner */
        .sched-banner { position:fixed; top:58px; left:0; right:0; z-index:99; background:#0f2a4a; border-bottom:2px solid #3b82f6; padding:10px 16px; display:flex; align-items:flex-start; gap:10px; }
        .sched-banner i { color:#60a5fa; font-size:1.1rem; flex-shrink:0; margin-top:2px; }
        .sched-banner-text { font-size:.78rem; color:#cbd5e1; flex:1; line-height:1.45; }
        .sched-banner-close { background:none; border:none; color:#64748b; font-size:1.1rem; cursor:pointer; padding:0 4px; flex-shrink:0; }
        .sched-banner-close:hover { color:#f87171; }
        /* Week schedule card */
        .week-sched-card { background:#0f172a; border:1.5px solid #1e3a5f; border-radius:14px; padding:13px 15px; margin-bottom:10px; }
        .week-sched-route { font-weight:700; font-size:.95rem; color:#e2e8f0; }
        .week-sched-sub { font-size:.74rem; color:#64748b; margin-top:2px; }
        .week-sched-meta { display:flex; align-items:center; gap:10px; margin-top:8px; flex-wrap:wrap; }
        .shift-pill { font-size:.68rem; font-weight:800; padding:3px 10px; border-radius:20px; text-transform:uppercase; letter-spacing:.06em; }
        .shift-Morning  { background:#0d2a1f; color:#34d399; border:1px solid #064e3b; }
        .shift-Afternoon{ background:#1e1a07; color:#fbbf24; border:1px solid #713f12; }
        .shift-Shuttle  { background:#0d1f3c; color:#60a5fa; border:1px solid #1e3a5f; }
    </style>
</head>
<body>
<div id="map"></div>

<div class="topbar">
    <button class="menu-btn" onclick="toggleSheet()"><i class="bi bi-list"></i></button>
    <div class="driver-pill">
        <span class="dot"></span>
        <i class="bi bi-person-fill"></i> ${sessionScope.loggedUser.name}
    </div>
    <a href="${pageContext.request.contextPath}/users/logout" class="logout-btn" title="Logout">
        <i class="bi bi-box-arrow-right"></i>
    </a>
</div>

<%-- Trip-start error banner (set by DriverServlet when start is blocked) --%>
<c:if test="${not empty sessionScope.tripStartError}">
<div id="trip-start-error" style="position:fixed;top:0;left:0;right:0;z-index:9999;background:#dc2626;color:#fff;font-size:.85rem;font-weight:600;padding:10px 16px;text-align:center;display:flex;align-items:center;justify-content:center;gap:8px">
    <i class="bi bi-exclamation-triangle-fill"></i>
    ${sessionScope.tripStartError}
    <button onclick="this.parentElement.style.display='none'" style="background:none;border:none;color:#fff;font-size:1.1rem;cursor:pointer;margin-left:8px">&times;</button>
</div>
<c:remove var="tripStartError" scope="session"/>
</c:if>

<%-- Schedule notification banner (shown when a new schedule has been posted) --%>
<c:if test="${not empty scheduleNotifs}">
<div class="sched-banner" id="sched-banner">
    <i class="bi bi-calendar-check-fill"></i>
    <div class="sched-banner-text">
        <strong style="color:#60a5fa">New Schedule Posted</strong>&nbsp;
        ${scheduleNotifs[0].message}
        <c:if test="${fn:length(scheduleNotifs) > 1}">
            &nbsp;<span style="color:#475569">+${fn:length(scheduleNotifs)-1} more</span>
        </c:if>
    </div>
    <button class="sched-banner-close" onclick="document.getElementById('sched-banner').style.display='none'" title="Dismiss">&times;</button>
</div>
</c:if>

<div class="bottom-sheet" id="bottom-sheet">
    <div class="sheet-handle" id="drv-handle">
        <div class="sheet-bar"></div>
        <span id="drv-hint" class="sheet-hint">DRAG TO RESIZE</span>
    </div>
    <div class="sheet-content" id="dd-sheet-content">
        <c:set var="active" value="0"/>
        <c:set var="done" value="0"/>
        <c:set var="total" value="0"/>
        <c:forEach var="t" items="${trips}">
            <c:set var="total" value="${total + 1}"/>
            <c:if test="${t.status == 'IN_PROGRESS'}"><c:set var="active" value="${active + 1}"/></c:if>
            <c:if test="${t.status == 'COMPLETED'}"><c:set var="done" value="${done + 1}"/></c:if>
        </c:forEach>
        <div class="stats-bar">
            <div class="stat-chip"><div class="stat-num green">${active}</div><div class="stat-lbl">On the Road</div></div>
            <div class="stat-chip"><div class="stat-num purple">${total - active - done}</div><div class="stat-lbl">Coming Up</div></div>
            <div class="stat-chip"><div class="stat-num">${done}</div><div class="stat-lbl">Completed</div></div>
        </div>

        <div class="section-lbl">Your Trips This Week</div>
        <c:choose>
            <c:when test="${not empty trips}">
                <c:forEach var="t" items="${trips}">
                    <c:set var="cardCls" value="done"/>
                    <c:if test="${t.status == 'IN_PROGRESS'}"><c:set var="cardCls" value="live"/></c:if>
                    <c:if test="${t.status == 'SCHEDULED'}"><c:set var="cardCls" value="scheduled"/></c:if>
                    <div class="trip-card ${cardCls}" data-trip-id="${t.tripId}" data-status="${t.status}">
                        <div class="card-top">
                            <div class="card-icon ${cardCls}">
                                <c:choose>
                                    <c:when test="${t.status == 'IN_PROGRESS'}"><i class="bi bi-broadcast-pin" style="color:#16a34a"></i></c:when>
                                    <c:when test="${t.status == 'SCHEDULED'}"><i class="bi bi-bus-front-fill" style="color:#7c3aed"></i></c:when>
                                    <c:otherwise><i class="bi bi-check-circle-fill" style="color:#6b7280"></i></c:otherwise>
                                </c:choose>
                            </div>
                            <div>
                                <div class="card-title">${t.route.routeName}</div>
                                <div class="card-sub">
                                    Bus: ${t.bus.registrationNumber}
                                    &nbsp;&middot;&nbsp; Trip #${t.tripId}
                                </div>
                                <c:if test="${t.startTime != null}">
                                <div class="card-sub" style="margin-top:2px;font-weight:600;color:#60a5fa">
                                    <i class="bi bi-calendar3"></i>
                                    <time class="fmt-dt" data-dt="${t.startTime}"></time>
                                </div>
                                </c:if>
                            </div>
                            <c:choose>
                                <c:when test="${t.status == 'IN_PROGRESS'}"><span class="card-badge live"><i class="bi bi-broadcast-pin"></i> On the road</span></c:when>
                                <c:when test="${t.status == 'SCHEDULED'}"><span class="card-badge scheduled">Ready to start</span></c:when>
                                <c:otherwise><span class="card-badge done">Completed</span></c:otherwise>
                            </c:choose>
                        </div>
                        <div class="card-actions">
                            <c:if test="${t.status == 'SCHEDULED'}">
                                <button class="btn-action btn-go"
                                   data-trip-id="${t.tripId}"
                                   data-depart-time="${t.startTime}"
                                   data-start-lat="${not empty t.route.startLat ? t.route.startLat : ''}"
                                   data-start-lng="${not empty t.route.startLng ? t.route.startLng : ''}"
                                   data-start-loc="${fn:escapeXml(t.route.startLocation)}"
                                   onclick="handleStartBtn(this)">
                                    <i class="bi bi-play-fill"></i> Start My Trip
                                </button>
                            </c:if>
                            <c:if test="${t.status == 'IN_PROGRESS'}">
                                <a href="${pageContext.request.contextPath}/tracking/drive?tripId=${t.tripId}" class="btn-action btn-map"><i class="bi bi-geo-alt-fill"></i> Share My Location</a>
                                <button class="btn-action btn-delay" onclick="openDelayModal(${t.tripId})"><i class="bi bi-exclamation-triangle-fill"></i> Report a Delay</button>
                                <a href="${pageContext.request.contextPath}/driver/end?id=${t.tripId}" class="btn-action btn-end" onclick="return confirm('Are you sure you want to end this trip?')"><i class="bi bi-stop-fill"></i> End Trip</a>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <i class="bi bi-bus-front"></i><br>
                    <b>No trips assigned for this week.</b><br>
                    <span style="font-size:.78rem;color:#64748b">Your supervisor will publish the schedule before the week starts.</span>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<div id="dd-overlay">
    <div id="dd-modal">
        <h5><i class="bi bi-exclamation-triangle-fill me-2"></i>Report a Delay to Passengers</h5>
        <p>Choose what's causing the delay &mdash; passengers on this trip will be notified immediately so they can plan ahead.</p>
        <button class="dd-reason" onclick="ddSelectReason(this,'Heavy traffic')"><i class="bi bi-car-front-fill"></i> Heavy traffic</button>
        <button class="dd-reason" onclick="ddSelectReason(this,'Road accident ahead')"><i class="bi bi-exclamation-octagon-fill"></i> Road accident ahead</button>
        <button class="dd-reason" onclick="ddSelectReason(this,'Bus mechanical issue')"><i class="bi bi-tools"></i> Bus mechanical issue</button>
        <button class="dd-reason" onclick="ddSelectReason(this,'Weather conditions')"><i class="bi bi-cloud-rain-fill"></i> Weather conditions</button>
        <button class="dd-reason" onclick="ddSelectReason(this,'Passenger boarding delay')"><i class="bi bi-people-fill"></i> Boarding delay</button>
        <input id="dd-custom" type="text" placeholder="Or type a custom reason..." maxlength="200" oninput="ddCustomReason(this)"/>
        <div id="dd-done"><i class="bi bi-check-circle-fill"></i> Passengers have been notified! They can now plan a different route if needed.</div>
        <button id="dd-submit" onclick="submitDashDelay()">Send Alert</button>
        <button id="dd-cancel" onclick="closeDelayModal()">Cancel</button>
    </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
const DD_CTX = '${pageContext.request.contextPath}';
let ddTripId = null, ddReason = '', sheetCollapsed = false;
const DD_SHEET = () => document.getElementById('bottom-sheet');

// Format ISO datetimes in trip cards (e.g. "2026-05-12T12:01" → "Tue 12 May at 12:01")
document.querySelectorAll('time.fmt-dt').forEach(el => {
    const raw = el.dataset.dt; // "2026-05-12T12:01:00" or "2026-05-12T12:01"
    if (!raw) return;
    const d = new Date(raw.replace('T', ' ')); // Safari-safe parse
    if (isNaN(d)) { el.textContent = raw; return; }
    el.textContent = d.toLocaleString('en-ZA', { weekday:'short', day:'numeric', month:'short', hour:'2-digit', minute:'2-digit', hour12:false });
});

// -- MAP --
const map = L.map('map', { zoomControl: false, attributionControl: false });
L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', { maxZoom: 19 }).addTo(map);
L.control.zoom({ position: 'topright' }).addTo(map);

navigator.geolocation
    ? navigator.geolocation.getCurrentPosition(p => map.setView([p.coords.latitude, p.coords.longitude], 14), () => map.setView([0,0],2))
    : map.setView([0,0], 2);

// Show markers for in-progress trips
const liveTrips = [];
<c:forEach var="t" items="${trips}"><c:if test="${t.status == 'IN_PROGRESS'}">liveTrips.push({ id: ${t.tripId}, name: "${t.route.routeName}" });</c:if></c:forEach>
liveTrips.forEach(t => {
    fetch(DD_CTX + '/tracking/latest?tripId=' + t.id).then(r => r.json()).then(d => {
        if (d && d.lat && d.lng) {
            const ic = L.divIcon({ className: '', html: '<div style="background:#00c853;border-radius:50%;width:18px;height:18px;border:3px solid #fff;box-shadow:0 0 0 5px rgba(0,200,83,.3)"></div>', iconSize:[18,18], iconAnchor:[9,9] });
            L.marker([d.lat, d.lng], { icon: ic }).addTo(map).bindPopup('<b>' + t.name + '</b><br>Your current location');
            map.setView([d.lat, d.lng], 14);
        }
    }).catch(() => {});
});

// -- SHEET --
function toggleSheet() {
    sheetCollapsed = !sheetCollapsed;
    const sheet = DD_SHEET();
    const hint  = document.getElementById('drv-hint');
    sheet.style.transition = '';
    if (sheetCollapsed) { sheet.classList.add('collapsed');    hint.textContent = 'DRAG UP FOR DETAILS'; }
    else                { sheet.classList.remove('collapsed'); hint.textContent = 'DRAG TO RESIZE'; }
}
(function() {
    const handle = document.getElementById('drv-handle');
    const sheet  = DD_SHEET();
    let startY = 0, startH = 0, dragging = false;
    function onStart(e) {
        dragging = true;
        startY = e.touches ? e.touches[0].clientY : e.clientY;
        startH = sheet.getBoundingClientRect().height;
        sheet.style.transition = 'none';
    }
    function onMove(e) {
        if (!dragging) return;
        e.preventDefault();
        const y = e.touches ? e.touches[0].clientY : e.clientY;
        const newH = Math.max(52, Math.min(window.innerHeight * 0.88, startH + (startY - y)));
        sheet.style.height = newH + 'px';
    }
    function onEnd() {
        if (!dragging) return;
        dragging = false;
        const h = sheet.getBoundingClientRect().height;
        const vh = window.innerHeight;
        sheet.style.height = '';
        sheet.style.transition = '';
        if (h < vh * 0.2) { sheetCollapsed = true;  sheet.classList.add('collapsed');    document.getElementById('drv-hint').textContent = 'DRAG UP FOR DETAILS'; }
        else               { sheetCollapsed = false; sheet.classList.remove('collapsed'); document.getElementById('drv-hint').textContent = 'DRAG TO RESIZE'; }
    }
    handle.addEventListener('touchstart', onStart, { passive: true });
    handle.addEventListener('touchmove',  onMove,  { passive: false });
    handle.addEventListener('touchend',   onEnd);
    handle.addEventListener('mousedown',  onStart);
    document.addEventListener('mousemove', onMove);
    document.addEventListener('mouseup',   onEnd);
    handle.addEventListener('click', toggleSheet);
})();

// -- DELAY MODAL --
function openDelayModal(tripId) {
    ddTripId = tripId; ddReason = '';
    document.querySelectorAll('.dd-reason').forEach(b => b.classList.remove('selected'));
    document.getElementById('dd-custom').value = '';
    document.getElementById('dd-done').style.display = 'none';
    document.getElementById('dd-submit').style.display = 'block';
    document.getElementById('dd-cancel').textContent = 'Cancel';
    document.getElementById('dd-overlay').classList.add('open');
}
function closeDelayModal() { document.getElementById('dd-overlay').classList.remove('open'); }
function ddSelectReason(btn, reason) { document.querySelectorAll('.dd-reason').forEach(b => b.classList.remove('selected')); btn.classList.add('selected'); ddReason = reason; document.getElementById('dd-custom').value = ''; }
function ddCustomReason(input) { document.querySelectorAll('.dd-reason').forEach(b => b.classList.remove('selected')); ddReason = input.value.trim(); }
function submitDashDelay() {
    const reason = ddReason || document.getElementById('dd-custom').value.trim();
    if (!reason) { alert('Please select or type a reason.'); return; }
    fetch(DD_CTX + '/notifications/report-delay', { method: 'POST', body: new URLSearchParams({ tripId: ddTripId, reason }) })
        .then(r => r.json()).then(data => {
            if (data.ok) { document.getElementById('dd-submit').style.display = 'none'; document.getElementById('dd-done').style.display = 'block'; document.getElementById('dd-cancel').textContent = 'Close'; setTimeout(closeDelayModal, 2000); }
            else { alert('Error: ' + (data.error || 'unknown')); }
        }).catch(() => alert('Network error'));
}

// ── Trip start: time-lock logic ─────────────────────────────────────────
function parseDepartMin(raw) {
    // handles LocalTime "14:00" / "14:00:00" and LocalDateTime "2026-05-12T14:00"
    if (!raw || raw === 'null') return null;
    const timePart = raw.includes('T') ? raw.split('T')[1] : raw;
    const parts = timePart.split(':');
    return parseInt(parts[0]) * 60 + parseInt(parts[1]);
}

function refreshStartButtons() {
    const now = new Date();
    const nowMin = now.getHours() * 60 + now.getMinutes();
    const pad = n => String(n).padStart(2, '0');
    document.querySelectorAll('button[data-depart-time]').forEach(btn => {
        const tripMin = parseDepartMin(btn.getAttribute('data-depart-time'));
        if (tripMin === null) { btn.disabled = false; return; }
        const diff = tripMin - nowMin; // positive = still in future
        const h = Math.floor(tripMin / 60), m = tripMin % 60;
        if (diff > 15) {
            // Too early — locked
            btn.disabled = true;
            btn.classList.remove('window-passed');
            btn.innerHTML = `<i class="bi bi-lock-fill"></i> Available at ${pad(h)}:${pad(m)}`;
        } else if (diff < -60) {
            // Grace period expired
            btn.disabled = true;
            btn.classList.add('window-passed');
            btn.innerHTML = '<i class="bi bi-clock-history"></i> Window passed';
        } else {
            // It\'s time
            btn.disabled = false;
            btn.classList.remove('window-passed');
            btn.innerHTML = '<i class="bi bi-play-fill"></i> Start My Trip';
        }
    });
}

function handleStartBtn(btn) {
    if (btn.disabled) return;
    startTripCheck(
        btn.getAttribute('data-trip-id'),
        parseFloat(btn.getAttribute('data-start-lat')) || null,
        parseFloat(btn.getAttribute('data-start-lng')) || null,
        btn.getAttribute('data-start-loc')
    );
}

// ── Trip start: GPS location check ────────────────────────────────────────
function haversineKm(lat1, lng1, lat2, lng2) {
    const R = 6371, toRad = x => x * Math.PI / 180;
    const dLat = toRad(lat2 - lat1), dLng = toRad(lng2 - lng1);
    const a = Math.sin(dLat/2)**2 + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng/2)**2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function startTripCheck(tripId, startLat, startLng, locationName) {
    const doStart = () => {
        if ('vibrate' in navigator) navigator.vibrate([150, 80, 150, 80, 300]);
        location.href = DD_CTX + '/driver/start?id=' + tripId;
    };

    if (!startLat || !startLng || isNaN(startLat) || isNaN(startLng)) {
        if (confirm('Are you ready to start this trip?')) doStart();
        return;
    }

    navigator.geolocation.getCurrentPosition(
        function(pos) {
            const distKm = haversineKm(pos.coords.latitude, pos.coords.longitude, startLat, startLng);
            if (distKm > 0.5) {
                alert('You are ' + distKm.toFixed(2) + ' km away from the departure point (\'' + locationName + '\').\n\nPlease drive to the departure point first, then start the trip.');
                return;
            }
            if (confirm('You are at the departure point. Ready to start this trip?')) doStart();
        },
        function() {
            if (confirm('We could not detect your location.\nStart the trip anyway?')) doStart();
        },
        { enableHighAccuracy: true, timeout: 8000, maximumAge: 0 }
    );
}

(function() {
    const mapMarkers = [];
    async function autoRefresh() {
        try {
            const res = await fetch(location.href, { credentials: 'same-origin' });
            if (!res.ok) return;
            const doc = new DOMParser().parseFromString(await res.text(), 'text/html');
            const fresh = doc.getElementById('dd-sheet-content');
            const curr  = document.getElementById('dd-sheet-content');
            if (fresh && curr) curr.outerHTML = fresh.outerHTML;
            // refresh map markers for in-progress trips
            mapMarkers.forEach(m => map.removeLayer(m));
            mapMarkers.length = 0;
            doc.querySelectorAll('[data-trip-id][data-status="IN_PROGRESS"]').forEach(el => {
                const tid = el.getAttribute('data-trip-id');
                fetch(DD_CTX + '/tracking/latest?tripId=' + tid).then(r => r.json()).then(d => {
                    if (d && d.lat && d.lng) {
                        const ic = L.divIcon({ className: '', html: '<div style="background:#00c853;border-radius:50%;width:18px;height:18px;border:3px solid #fff;box-shadow:0 0 0 5px rgba(0,200,83,.3)"></div>', iconSize:[18,18], iconAnchor:[9,9] });
                        const m = L.marker([d.lat, d.lng], { icon: ic }).addTo(map);
                        mapMarkers.push(m);
                    }
                }).catch(() => {});
            });
        } catch (e) { /* silent */ }
    }
    setInterval(autoRefresh, 10000);
})();

// Run time-lock check immediately and every 30 seconds
refreshStartButtons();
setInterval(refreshStartButtons, 30000);
</script>
</body>
</html>
