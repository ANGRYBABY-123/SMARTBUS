<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>SmartBus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        html, body { height: 100%; overflow: hidden; font-family: "Segoe UI", sans-serif; }
        #map { position: fixed; inset: 0; width: 100%; height: 100%; z-index: 1; }

        /* Top bar */
        .topbar { position: fixed; top: 0; left: 0; right: 0; z-index: 100; display: flex; align-items: center; padding: 12px 16px; gap: 10px; pointer-events: none; }
        .topbar > * { pointer-events: all; }
        .brand-pill { background: #fff; border-radius: 50px; padding: 8px 18px; font-weight: 800; font-size: 1rem; letter-spacing: -.3px; box-shadow: 0 2px 14px rgba(0,0,0,.2); }
        .brand-pill span { color: #00c853; }
        .icon-btn { width: 44px; height: 44px; background: #fff; border-radius: 50%; border: none; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 1.1rem; box-shadow: 0 2px 14px rgba(0,0,0,.2); text-decoration: none; color: #333; transition: background .2s; }
        .icon-btn:hover { background: #f0f0f0; }
        .notif-wrap { position: relative; margin-left: auto; }
        .notif-badge { position: absolute; top: -3px; right: -3px; background: #ef4444; color: #fff; border-radius: 50%; width: 18px; height: 18px; font-size: .62rem; font-weight: 800; display: none; align-items: center; justify-content: center; }
        .notif-badge.visible { display: flex; }
        .notif-dropdown { display: none; position: absolute; right: 0; top: 50px; width: 310px; background: #fff; border-radius: 16px; box-shadow: 0 8px 32px rgba(0,0,0,.18); z-index: 500; overflow: hidden; }
        .notif-dropdown.open { display: block; }
        .notif-drop-header { padding: 12px 16px 8px; font-weight: 800; font-size: .85rem; color: #111; border-bottom: 1px solid #f0f0f0; }
        .notif-item { padding: 11px 16px; display: flex; gap: 10px; align-items: flex-start; border-bottom: 1px solid #f7f7f7; font-size: .82rem; }
        .notif-item.delay { border-left: 4px solid #f59e0b; }
        .notif-msg { flex: 1; color: #333; line-height: 1.45; }
        .notif-time { font-size: .7rem; color: #aaa; margin-top: 3px; }
        .notif-empty { padding: 24px; text-align: center; color: #bbb; font-size: .85rem; }

        /* Bottom sheet */
        .bottom-sheet { position: fixed; bottom: 0; left: 0; right: 0; z-index: 100; background: #fff; border-radius: 24px 24px 0 0; box-shadow: 0 -4px 32px rgba(0,0,0,.16); transition: transform .35s cubic-bezier(.32,.72,0,1); max-height: 80vh; overflow-y: auto; }
        .sheet-handle { display: flex; justify-content: center; padding: 14px 0 6px; cursor: grab; }
        .sheet-handle::after { content: ""; width: 40px; height: 4px; background: #e0e0e0; border-radius: 4px; }
        .sheet-content { padding: 0 18px 32px; }

        /* Where to bar */
        .where-to { display: flex; align-items: center; gap: 12px; background: #f7f8fa; border-radius: 16px; padding: 14px 16px; margin-bottom: 20px; cursor: pointer; transition: background .15s; }
        .where-to:hover { background: #eef0f3; }
        .where-to i { font-size: 1.1rem; color: #aaa; }
        .where-to span { font-size: .95rem; color: #aaa; font-weight: 500; }

        /* Section */
        .section-lbl { font-size: .7rem; text-transform: uppercase; letter-spacing: 1.2px; color: #aaa; margin-bottom: 10px; font-weight: 700; display: flex; align-items: center; gap: 6px; }
        .live-dot { width: 7px; height: 7px; border-radius: 50%; background: #00c853; animation: pulse 1.4s infinite; }
        @keyframes pulse { 0%,100%{box-shadow:0 0 0 0 rgba(0,200,83,.5)} 50%{box-shadow:0 0 0 6px rgba(0,200,83,0)} }

        /* Trip card */
        .trip-card { border-radius: 16px; padding: 16px; margin-bottom: 12px; border: 1.5px solid #f0f0f0; background: #fff; display: flex; align-items: center; gap: 14px; transition: box-shadow .2s; }
        .trip-card:hover { box-shadow: 0 4px 18px rgba(0,0,0,.08); }
        .trip-card.live { border-color: #00c853; background: #f0fff4; }
        .trip-card.scheduled { border-color: #6366f1; background: #f5f3ff; }
        .card-icon { width: 50px; height: 50px; border-radius: 14px; font-size: 1.5rem; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .card-icon.live { background: #dcfce7; }
        .card-icon.scheduled { background: #ede9fe; }
        .card-body { flex: 1; min-width: 0; }
        .card-title { font-weight: 700; font-size: .98rem; color: #111; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .card-sub { font-size: .78rem; color: #888; margin-top: 2px; }
        .card-badge { font-size: .68rem; font-weight: 800; padding: 3px 9px; border-radius: 20px; text-transform: uppercase; white-space: nowrap; display: inline-block; margin-top: 5px; }
        .card-badge.live { background: #dcfce7; color: #16a34a; }
        .card-badge.sched { background: #ede9fe; color: #7c3aed; }
        .track-btn { background: #1a1a1a; color: #fff; border: none; padding: 11px 18px; border-radius: 12px; font-weight: 700; font-size: .85rem; text-decoration: none; white-space: nowrap; display: flex; align-items: center; gap: 6px; transition: background .2s; flex-shrink: 0; }
        .track-btn:hover { background: #00c853; color: #000; }
        .track-btn.disabled { background: #e0e0e0; color: #999; pointer-events: none; }
        .empty-state { text-align: center; padding: 36px 16px; color: #bbb; }
        .empty-state i { font-size: 2.6rem; display: block; margin-bottom: 10px; }
    </style>
</head>
<body>
<div id="map"></div>

<!-- Top bar -->
<div class="topbar">
    <div class="brand-pill">Smart<span>Bus</span></div>
    <div class="notif-wrap" style="margin-left:auto">
        <button class="icon-btn" onclick="toggleNotif()" title="Notifications">
            <i class="bi bi-bell-fill"></i>
            <span class="notif-badge" id="notif-badge">0</span>
        </button>
        <div class="notif-dropdown" id="notif-dropdown">
            <div class="notif-drop-header">?? Notifications</div>
            <div id="notif-list"><div class="notif-empty">No notifications yet</div></div>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/users/logout" class="icon-btn" title="Logout"><i class="bi bi-box-arrow-right"></i></a>
</div>

<!-- Bottom sheet -->
<div class="bottom-sheet" id="bottom-sheet">
    <div class="sheet-handle" onclick="toggleSheet()"></div>
    <div class="sheet-content" id="pass-sheet-content">

        <!-- Where to bar -->
        <div class="where-to">
            <i class="bi bi-search"></i>
            <span>Where to? &nbsp;�&nbsp; Track a bus</span>
        </div>

        <!-- Live Now -->
        <div class="section-lbl"><span class="live-dot"></span> Live Now</div>
        <c:choose>
            <c:when test="${not empty activeTrips}">
                <c:forEach var="t" items="${activeTrips}">
                    <div class="trip-card live" data-live-trip="${t.tripId}" data-trip-name="${t.route.routeName}" data-driver="${t.driver.name}">
                        <div class="card-icon live">??</div>
                        <div class="card-body">
                            <div class="card-title">${t.route.routeName}</div>
                            <div class="card-sub"><i class="bi bi-person-fill"></i> ${t.driver.name} &nbsp;�&nbsp; <i class="bi bi-bus-front-fill"></i> ${t.bus.registrationNumber}</div>
                            <span class="card-badge live">? Live</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/tracking/view?tripId=${t.tripId}" class="track-btn" target="_blank"><i class="bi bi-geo-alt-fill"></i> Track</a>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="empty-state"><i class="bi bi-bus-front"></i>No buses active right now</div>
            </c:otherwise>
        </c:choose>

        <!-- Upcoming -->
        <div class="section-lbl" style="margin-top:16px"><i class="bi bi-calendar3" style="color:#6366f1"></i> Upcoming</div>
        <c:choose>
            <c:when test="${not empty scheduledTrips}">
                <c:forEach var="t" items="${scheduledTrips}">
                    <div class="trip-card scheduled">
                        <div class="card-icon scheduled">??</div>
                        <div class="card-body">
                            <div class="card-title">${t.route.routeName}</div>
                            <div class="card-sub">
                                <i class="bi bi-person-fill"></i> ${t.driver.name}
                                &nbsp;�&nbsp; <i class="bi bi-bus-front-fill"></i> ${t.bus.registrationNumber}
                                <c:if test="${t.startTime != null}">&nbsp;�&nbsp; <i class="bi bi-clock"></i> ${t.startTime}</c:if>
                            </div>
                            <span class="card-badge sched">Scheduled</span>
                        </div>
                        <span class="track-btn disabled"><i class="bi bi-clock"></i> Soon</span>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="empty-state" style="padding:20px 16px"><i class="bi bi-calendar-x" style="font-size:1.8rem"></i>No upcoming trips</div>
            </c:otherwise>
        </c:choose>

    </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
const CTX_DASH = '${pageContext.request.contextPath}';
let sheetCollapsed = false;
let notifOpen = false;
let dashNotifs = [];

// -- MAP --
const map = L.map('map', { zoomControl: false, attributionControl: false });
L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', { maxZoom: 19 }).addTo(map);
L.control.zoom({ position: 'topright' }).addTo(map);

navigator.geolocation
    ? navigator.geolocation.getCurrentPosition(p => map.setView([p.coords.latitude, p.coords.longitude], 14), () => map.setView([0,0],2))
    : map.setView([0,0], 2);

// Drop live bus markers on map
const busIcon = L.divIcon({
    className: '',
    html: '<div style="background:#00c853;width:20px;height:20px;border-radius:50%;border:3px solid #fff;box-shadow:0 0 0 4px rgba(0,200,83,.3)"></div>',
    iconSize: [20,20], iconAnchor: [10,10]
});
const liveTrips = [];
<c:forEach var="t" items="${activeTrips}">liveTrips.push({ id: ${t.tripId}, name: "${t.route.routeName}", driver: "${t.driver.name}" });</c:forEach>
liveTrips.forEach(t => {
    fetch(CTX_DASH + '/tracking/latest?tripId=' + t.id).then(r => r.json()).then(d => {
        if (d && d.lat && d.lng) {
            L.marker([d.lat, d.lng], { icon: busIcon }).addTo(map)
                .bindPopup('<b>' + t.name + '</b><br>Driver: ' + t.driver);
            if (liveTrips.length === 1) map.setView([d.lat, d.lng], 14);
        }
    }).catch(() => {});
});

// -- SHEET --
function toggleSheet() {
    sheetCollapsed = !sheetCollapsed;
    document.getElementById('bottom-sheet').style.transform = sheetCollapsed ? 'translateY(calc(100% - 68px))' : '';
}

// -- NOTIFICATIONS --
function toggleNotif() {
    notifOpen = !notifOpen;
    document.getElementById('notif-dropdown').classList.toggle('open', notifOpen);
    if (notifOpen) document.getElementById('notif-badge').classList.remove('visible');
}
document.addEventListener('click', e => {
    const w = document.querySelector('.notif-wrap');
    if (w && !w.contains(e.target)) { notifOpen = false; document.getElementById('notif-dropdown').classList.remove('open'); }
});
function pollNotifs() {
    fetch(CTX_DASH + '/notifications/unread').then(r => r.json()).then(notifs => {
        if (!notifs.length) return;
        const newOnes = notifs.filter(n => !dashNotifs.find(x => x.id === n.id));
        if (!newOnes.length) return;
        dashNotifs = notifs;
        const list = document.getElementById('notif-list');
        list.innerHTML = notifs.map(n => {
            const d = document.createElement('div'); d.textContent = n.message;
            return '<div class="notif-item' + (n.type==='DELAY'?' delay':'') + '">'
                + '<div style="font-size:1.2rem">' + (n.type==='DELAY'?'??':'??') + '</div>'
                + '<div class="notif-msg">' + d.innerHTML + '<div class="notif-time">' + n.time + '</div></div></div>';
        }).join('');
        document.getElementById('notif-badge').textContent = notifs.length;
        document.getElementById('notif-badge').classList.add('visible');
    }).catch(() => {});
}
setInterval(pollNotifs, 15000);
pollNotifs();

// ── Auto-refresh: swap trip cards (Live Now + Upcoming) every 10s ──
(function() {
    const busMarkers = [];
    async function autoRefreshPassenger() {
        try {
            const res = await fetch(location.href, { credentials: 'same-origin' });
            if (!res.ok) return;
            const doc = new DOMParser().parseFromString(await res.text(), 'text/html');
            const fresh = doc.getElementById('pass-sheet-content');
            const curr  = document.getElementById('pass-sheet-content');
            if (fresh && curr) curr.outerHTML = fresh.outerHTML;
            // refresh bus markers on map
            busMarkers.forEach(m => map.removeLayer(m));
            busMarkers.length = 0;
            doc.querySelectorAll('[data-live-trip]').forEach(el => {
                const tid = el.getAttribute('data-live-trip');
                const name = el.getAttribute('data-trip-name') || '';
                const driver = el.getAttribute('data-driver') || '';
                fetch(CTX_DASH + '/tracking/latest?tripId=' + tid).then(r => r.json()).then(d => {
                    if (d && d.lat && d.lng) {
                        const m = L.marker([d.lat, d.lng], { icon: busIcon })
                            .addTo(map).bindPopup('<b>' + name + '</b><br>Driver: ' + driver);
                        busMarkers.push(m);
                    }
                }).catch(() => {});
            });
        } catch (e) { /* silent */ }
    }
    setInterval(autoRefreshPassenger, 10000);
})();
</script>
</body>
</html>
