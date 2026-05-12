<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
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

        /* Terminal recommendation card */
        #terminal-rec {
            border-radius: 16px; padding: 14px 16px; margin-bottom: 18px;
            display: flex; align-items: center; gap: 14px;
            border: 1.5px solid #e0e7ff; background: #f5f3ff;
            transition: background .3s, border-color .3s;
        }
        #terminal-rec.out-of-range { background: #fff7ed; border-color: #fed7aa; }
        #terminal-rec.loading { background: #f7f8fa; border-color: #e5e7eb; }
        #terminal-rec.denied  { background: #fef2f2; border-color: #fecaca; }
        .trec-icon { width: 46px; height: 46px; border-radius: 13px; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; flex-shrink: 0; background: #ede9fe; }
        #terminal-rec.out-of-range .trec-icon { background: #ffedd5; }
        #terminal-rec.loading      .trec-icon { background: #f0f0f0; }
        #terminal-rec.denied       .trec-icon { background: #fee2e2; }
        #trec-title { font-weight: 700; font-size: .93rem; color: #111; }
        #trec-sub   { font-size: .76rem; color: #777; margin-top: 2px; }
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
        <!-- Terminal recommendation -->
        <div id="terminal-rec" class="loading">
            <div class="trec-icon"><i class="bi bi-compass"></i></div>
            <div>
                <div id="trec-title">Finding your nearest terminal…</div>
                <div id="trec-sub">Detecting your location</div>
            </div>
        </div>
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
                        <div class="card-icon live"><i class="bi bi-geo-alt-fill" style="font-size:1.3rem;color:#00c853"></i></div>
                        <div class="card-body">
                            <div class="card-title">${t.route.routeName}</div>
                            <div class="card-sub"><i class="bi bi-person-fill"></i> ${t.driver.name} &nbsp;&middot;&nbsp; <i class="bi bi-bus-front-fill"></i> ${t.bus.registrationNumber}</div>
                            <span class="card-badge live"><i class="bi bi-broadcast"></i> Live</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/tracking/view?tripId=${t.tripId}" class="track-btn"><i class="bi bi-geo-alt-fill"></i> Track</a>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="empty-state"><i class="bi bi-bus-front"></i>No buses active right now</div>
            </c:otherwise>
        </c:choose>

        <!-- Upcoming Today -->
        <div class="section-lbl" style="margin-top:16px">
            <i class="bi bi-calendar3" style="color:#6366f1"></i>
            Today's Trips &nbsp;<span style="font-size:.65rem;color:#aaa;font-weight:400;text-transform:none;letter-spacing:0">${today}</span>
        </div>
        <c:choose>
            <c:when test="${not empty scheduledTrips}">
                <c:forEach var="t" items="${scheduledTrips}">
                    <div class="trip-card scheduled">
                        <div class="card-icon scheduled"><i class="bi bi-bus-front-fill" style="font-size:1.3rem;color:#6366f1"></i></div>
                        <div class="card-body">
                            <div class="card-title">${t.route.routeName}</div>
                            <div class="card-sub">
                                <i class="bi bi-person-fill"></i> ${t.driver.name}
                                &nbsp;&middot;&nbsp; <i class="bi bi-bus-front-fill"></i> ${t.bus.registrationNumber}
                                <c:if test="${t.startTime != null}">&nbsp;&middot;&nbsp; <i class="bi bi-clock"></i>
                                    <%-- LocalDateTime.toString() = 2026-05-08T07:30 — take only HH:mm --%>
                                    ${fn:substring(t.startTime.toString(), 11, 16)}
                                </c:if>
                            </div>
                            <span class="card-badge sched">Scheduled</span>
                        </div>
                        <span class="track-btn disabled"><i class="bi bi-clock"></i> Soon</span>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="empty-state" style="padding:20px 16px"><i class="bi bi-calendar-check" style="font-size:1.8rem"></i>No trips scheduled for today</div>
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

// ── Nearest terminal recommendation (real bus stops from DB) ──────────────
(function () {
    function setRec(cls, icon, title, sub) {
        const el = document.getElementById('terminal-rec');
        el.className = cls;
        el.querySelector('.trec-icon').innerHTML = '<i class="bi bi-' + icon + '"></i>';
        document.getElementById('trec-title').textContent = title;
        document.getElementById('trec-sub').textContent   = sub;
    }

    function onPos(pos) {
        const uLat = pos.coords.latitude, uLng = pos.coords.longitude;
        L.circleMarker([uLat, uLng], {
            radius: 8, color: '#6366f1', fillColor: '#6366f1',
            fillOpacity: 0.85, weight: 2
        }).addTo(map).bindPopup('Your location');

        setRec('loading', 'compass', 'Finding nearest bus stop…', 'Checking GPS');
        fetch(CTX_DASH + '/stops/nearest?lat=' + uLat + '&lng=' + uLng)
            .then(r => r.json()).then(stops => {
                if (!stops.length) {
                    setRec('out-of-range', 'exclamation-triangle-fill',
                        'No stops nearby', 'No bus stops have been added to the system yet.');
                    return;
                }
                const s = stops[0];
                const routeNames = (s.routes && s.routes.length)
                    ? s.routes.map(r => r.name).join(', ')
                    : 'No routes assigned';
                setRec('', 'geo-alt-fill',
                    'Nearest stop: ' + s.name,
                    s.distKm + ' km away · Routes: ' + routeNames);
                map.setView([s.lat, s.lng], 14);
                stops.forEach(st => {
                    L.circleMarker([st.lat, st.lng], {
                        radius: 10, color: '#00c853', fillColor: '#00c853',
                        fillOpacity: 0.7, weight: 2
                    }).addTo(map).bindPopup(
                        '<b>' + st.name + '</b><br>' +
                        (st.routes ? st.routes.map(r => r.name).join(', ') : '')
                    );
                });
            }).catch(() => {
                setRec('denied', 'wifi-off', 'Could not load stops',
                    'Check your connection or try again later');
            });
    }

    function onErr(err) {
        const el = document.getElementById('terminal-rec');
        if (err.code === 1) {
            setRec('denied', 'geo-fill', 'Location access denied',
                'Enable location permission to see your nearest bus stop');
        } else {
            setRec('denied', 'wifi-off', 'Location unavailable',
                'Could not detect your position — try again later');
        }
    }

    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(onPos, onErr, {
            enableHighAccuracy: false, timeout: 5000, maximumAge: 300000
        });
    } else {
        setRec('denied', 'geo-fill', 'Geolocation not supported',
            'Your browser does not support location detection');
    }
})();

    function haversineKm(lat1, lng1, lat2, lng2) {
        const R = 6371;
        const dLat = (lat2 - lat1) * Math.PI / 180;
        const dLng = (lng2 - lng1) * Math.PI / 180;
        const a = Math.sin(dLat/2) * Math.sin(dLat/2)
            + Math.cos(lat1 * Math.PI/180) * Math.cos(lat2 * Math.PI/180)
            * Math.sin(dLng/2) * Math.sin(dLng/2);
        return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    function compassDir(lat1, lng1, lat2, lng2) {
        const dLng = (lng2 - lng1) * Math.PI / 180;
        const y = Math.sin(dLng) * Math.cos(lat2 * Math.PI/180);
        const x = Math.cos(lat1 * Math.PI/180) * Math.sin(lat2 * Math.PI/180)
            - Math.sin(lat1 * Math.PI/180) * Math.cos(lat2 * Math.PI/180) * Math.cos(dLng);
        const bearing = (Math.atan2(y, x) * 180 / Math.PI + 360) % 360;
        const dirs = ['N','NE','E','SE','S','SW','W','NW'];
        return dirs[Math.round(bearing / 45) % 8];
    }

    function setRec(cls, icon, title, sub) {
        const el = document.getElementById('terminal-rec');
        el.className = cls;
        el.querySelector('.trec-icon').innerHTML = '<i class="bi bi-' + icon + '"></i>';
        document.getElementById('trec-title').textContent = title;
        document.getElementById('trec-sub').textContent   = sub;
    }

    function onPos(pos) {
        const uLat = pos.coords.latitude, uLng = pos.coords.longitude;

        // Add a small user location dot to the map
        L.circleMarker([uLat, uLng], {
            radius: 8, color: '#6366f1', fillColor: '#6366f1',
            fillOpacity: 0.85, weight: 2
        }).addTo(map).bindPopup('Your location');

        // Find nearest campus
        let nearest = null, minDist = Infinity;
        CAMPUSES.forEach(c => {
            const d = haversineKm(uLat, uLng, c.lat, c.lng);
            if (d < minDist) { minDist = d; nearest = c; }
        });

        if (minDist > MAX_KM) {
            setRec(
                'out-of-range',
                'exclamation-triangle-fill',
                'Out of service area',
                'You are ' + minDist.toFixed(0) + ' km from the nearest TUT campus (' + nearest.name + '). SmartBus only serves within 100 km.'
            );
        } else {
            const dir = compassDir(uLat, uLng, nearest.lat, nearest.lng);
            const distTxt = minDist < 0.1 ? minDist.toFixed(3) + ' km' : minDist.toFixed(2) + ' km';
            setRec(
                '',
                'geo-alt-fill',
                'Nearest terminal: ' + nearest.name,
                distTxt + ' away · head ' + dir + ' · Board here for your route'
            );
            // Pan map to show user + campus
            map.fitBounds([[uLat, uLng], [nearest.lat, nearest.lng]], { padding: [60, 60] });
            L.circleMarker([nearest.lat, nearest.lng], {
                radius: 10, color: '#00c853', fillColor: '#00c853',
                fillOpacity: 0.7, weight: 2
            }).addTo(map).bindPopup('<b>' + nearest.name + '</b><br>Your recommended terminal').openPopup();
        }
    }

    function onErr(err) {
        if (err.code === 1) {
            setRec('denied', 'geo-fill', 'Location access denied',
                'Enable location permission to see your nearest terminal');
        } else {
            setRec('denied', 'wifi-off', 'Location unavailable',
                'Could not detect your position — try again later');
        }
    }

    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(onPos, onErr, {
            enableHighAccuracy: false, timeout: 5000, maximumAge: 300000
        });
    } else {
        setRec('denied', 'geo-fill', 'Geolocation not supported',
            'Your browser does not support location detection');
    }
})();

// ── Auto-refresh: swap trip cards (Live Now + Upcoming) every 10s ──
(function() {
    const CACHE_KEY = 'smartbus_cached_trips';
    // Offline: show cached data banner
    if (!navigator.onLine) {
        try {
            const cached = JSON.parse(localStorage.getItem(CACHE_KEY) || '{}');
            if (cached.ts && Date.now() - cached.ts < 3600000) {
                const whereToSpan = document.querySelector('.where-to span');
                if (whereToSpan) whereToSpan.textContent = '⚠️ Offline — showing cached data';
            }
        } catch (e) {}
    }
    const busMarkers = [];
    async function autoRefreshPassenger() {
        try {
            const res = await fetch(location.href, { credentials: 'same-origin' });
            if (!res.ok) return;
            const html = await res.text();
            const doc = new DOMParser().parseFromString(html, 'text/html');
            const fresh = doc.getElementById('pass-sheet-content');
            const curr  = document.getElementById('pass-sheet-content');
            if (fresh && curr) curr.outerHTML = fresh.outerHTML;
            // Cache trip data for offline use
            try {
                const liveCards  = document.querySelectorAll('[data-live-trip]');
                const cacheData  = { ts: Date.now(), liveCount: liveCards.length };
                localStorage.setItem(CACHE_KEY, JSON.stringify(cacheData));
            } catch (ce) {}
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
