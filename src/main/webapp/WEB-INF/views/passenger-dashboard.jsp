<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%
  String mapsKey = getServletContext().getInitParameter("google.maps.key");
  if (mapsKey == null || mapsKey.isBlank() || "YOUR_GOOGLE_MAPS_API_KEY".equals(mapsKey))
      mapsKey = System.getenv("GOOGLE_MAPS_KEY") != null ? System.getenv("GOOGLE_MAPS_KEY") : "";
  String gaMeasurementId = getServletContext().getInitParameter("ga.measurement.id");
  if (gaMeasurementId == null || "YOUR_GA4_MEASUREMENT_ID".equals(gaMeasurementId))
      gaMeasurementId = System.getenv("GA_MEASUREMENT_ID") != null ? System.getenv("GA_MEASUREMENT_ID") : "";
  String fbApiKey       = getServletContext().getInitParameter("firebase.api.key");
  String fbAuthDomain   = getServletContext().getInitParameter("firebase.auth.domain");
  String fbProjectId    = getServletContext().getInitParameter("firebase.project.id");
  String fbMsgSenderId  = getServletContext().getInitParameter("firebase.messaging.sender.id");
  String fbAppId        = getServletContext().getInitParameter("firebase.app.id");
  String fbVapidKey     = getServletContext().getInitParameter("firebase.vapid.key");
  boolean firebaseReady = fbApiKey != null && !fbApiKey.isBlank() && !"YOUR_FIREBASE_API_KEY".equals(fbApiKey);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>CommuteSafe</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <% if (!gaMeasurementId.isEmpty()) { %>
    <script async src="https://www.googletagmanager.com/gtag/js?id=<%= gaMeasurementId %>"></script>
    <script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments);}gtag('js',new Date());gtag('config','<%= gaMeasurementId %>');</script>
    <% } %>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        html, body { height: 100%; overflow: hidden; font-family: "Segoe UI", sans-serif; }
        #map { position: fixed; inset: 0; width: 100%; height: 100%; z-index: 1; }

        /* Top bar */
        .topbar { position: fixed; top: 0; left: 0; right: 0; z-index: 100; display: flex; align-items: center; padding: 12px 16px; gap: 10px; pointer-events: none; }
        .topbar > * { pointer-events: all; }
        .brand-pill { background: #fff; border-radius: 50px; padding: 7px 16px 7px 10px; font-weight: 800; font-size: 1rem; letter-spacing: -.3px; box-shadow: 0 2px 14px rgba(0,0,0,.2); display:flex; align-items:center; }
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

        /* Bottom sheet — starts partial so map is visible, expands/collapses on drag/tap */
        .bottom-sheet { position: fixed; bottom: 0; left: 0; right: 0; z-index: 100; background: #fff; border-radius: 24px 24px 0 0; box-shadow: 0 -4px 32px rgba(0,0,0,.16); height: 42vh; overflow-y: auto; transition: height .35s cubic-bezier(.32,.72,0,1); }
        .bottom-sheet.expanded { height: 78vh; }
        .bottom-sheet.collapsed { height: 52px; overflow: hidden; }
        .sheet-handle { display: flex; flex-direction: column; align-items: center; padding: 10px 0 6px; gap: 5px; cursor: grab; flex-shrink: 0; touch-action: none; }
        .sheet-bar { width: 40px; height: 4px; background: #e0e0e0; border-radius: 4px; }
        .sheet-hint { font-size: .6rem; color: #bbb; font-weight: 600; letter-spacing: .5px; }
        .sheet-content { padding: 0 18px 32px; }

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
        .card-title { font-weight: 700; font-size: .98rem; color: #111; }
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
    <div class="brand-pill">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20" style="flex-shrink:0;margin-right:5px" aria-hidden="true">
          <path d="M12 1.5L21 5.5L21 12.5C21 18.5 17 22.5 12 23.5C7 22.5 3 18.5 3 12.5L3 5.5Z" fill="#00c853"/>
          <path d="M12 4.5L19.5 8L19.5 12.5C19.5 17.5 16 21 12 22C8 21 4.5 17.5 4.5 12.5L4.5 8Z" fill="rgba(0,0,0,0.1)"/>
          <rect x="6.5" y="11" width="11" height="7.5" rx="1.8" fill="white"/>
          <rect x="7" y="8.5" width="10" height="3.5" rx="1.5" fill="rgba(255,255,255,0.93)"/>
          <rect x="7.5" y="12" width="2.8" height="2.5" rx="0.5" fill="#009c3b"/>
          <rect x="11.5" y="12" width="2.8" height="2.5" rx="0.5" fill="#009c3b"/>
          <circle cx="9" cy="18.8" r="1.6" fill="#009c3b"/>
          <circle cx="15" cy="18.8" r="1.6" fill="#009c3b"/>
        </svg>
        Commute<span>Safe</span>
    </div>
    <div class="notif-wrap" style="margin-left:auto">
        <button class="icon-btn" onclick="toggleNotif()" title="Notifications">
            <i class="bi bi-bell-fill"></i>
            <span class="notif-badge" id="notif-badge">0</span>
        </button>
        <div class="notif-dropdown" id="notif-dropdown">
            <div class="notif-drop-header"><i class="bi bi-bell-fill" style="color:#f59e0b"></i> Your Notifications</div>
            <div id="notif-list"><div class="notif-empty">You're all caught up! No alerts yet.</div></div>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/users/logout" class="icon-btn" title="Logout"><i class="bi bi-box-arrow-right"></i></a>
</div>

<!-- Bottom sheet -->
<div class="bottom-sheet" id="bottom-sheet">
    <div class="sheet-handle" id="pass-handle">
        <div class="sheet-bar"></div>
        <span id="sheet-hint" class="sheet-hint">DRAG UP FOR MORE</span>
    </div>
    <div class="sheet-content" id="pass-sheet-content">
        <!-- Greeting -->
        <div style="margin-bottom:14px;display:flex;align-items:center;justify-content:space-between">
            <div>
                <div style="font-size:1.05rem;font-weight:800;color:#111">Good <span id="time-greeting">day</span>, <c:out value="${sessionScope.loggedUser.name}"/>! 👋</div>
                <div style="font-size:.75rem;color:#aaa;margin-top:1px">Here are today's buses — tap <b>Track</b> to follow one live</div>
            </div>
            <div id="last-updated" style="font-size:.65rem;color:#bbb;text-align:right">Updated just now</div>
        </div>
        <!-- Terminal recommendation -->
        <div id="terminal-rec" class="loading">
            <div class="trec-icon"><i class="bi bi-compass"></i></div>
            <div>
                <div id="trec-title">Finding your nearest bus stop…</div>
                <div id="trec-sub">Allow location access when asked</div>
            </div>
        </div>


        <!-- Live Now -->
        <div class="section-lbl"><span class="live-dot"></span> Buses Running Now</div>
        <c:choose>
            <c:when test="${not empty activeTrips}">
                <c:forEach var="t" items="${activeTrips}">
                    <div class="trip-card live" data-live-trip="${t.tripId}" data-trip-name="${t.route.routeName}" data-driver="${t.driver.name}">
                        <div class="card-icon live"><i class="bi bi-geo-alt-fill" style="font-size:1.3rem;color:#00c853"></i></div>
                        <div class="card-body">
                            <div class="card-title">${t.route.routeName}</div>
                            <div class="card-sub">Driver: ${t.driver.name} &nbsp;&middot;&nbsp; Bus: ${t.bus.registrationNumber}</div>
                            <span class="card-badge live"><i class="bi bi-broadcast"></i> On the road now</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/tracking/view?tripId=${t.tripId}" class="track-btn"><i class="bi bi-geo-alt-fill"></i> Track</a>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <i class="bi bi-bus-front"></i>
                    <div style="font-weight:700;color:#555;margin-bottom:4px">No buses on the road yet</div>
                    <div style="font-size:.78rem">Check back shortly — buses typically depart from <b>05:30</b></div>
                </div>
            </c:otherwise>
        </c:choose>

        <!-- Upcoming Today -->
        <div class="section-lbl" style="margin-top:16px">
            <i class="bi bi-calendar3" style="color:#6366f1"></i>
            Coming Up Today &nbsp;<span style="font-size:.65rem;color:#aaa;font-weight:400;text-transform:none;letter-spacing:0">${today}</span>
        </div>
        <c:choose>
            <c:when test="${not empty scheduledTrips}">
                <c:forEach var="t" items="${scheduledTrips}">
                    <div class="trip-card scheduled">
                        <div class="card-icon scheduled"><i class="bi bi-bus-front-fill" style="font-size:1.3rem;color:#6366f1"></i></div>
                        <div class="card-body">
                            <div class="card-title">${t.route.routeName}</div>
                            <div class="card-sub">
                                Driver: ${t.driver.name}
                                &nbsp;&middot;&nbsp; Bus: ${t.bus.registrationNumber}
                                <c:if test="${t.startTime != null}">
                                    &nbsp;&middot;&nbsp; <i class="bi bi-clock"></i> Departs at ${fn:substring(t.startTime.toString(), 11, 16)}
                                </c:if>
                            </div>
                            <span class="card-badge sched">Arriving soon — not yet trackable</span>
                        </div>
                        <span class="track-btn disabled" title="Tracking starts when the bus departs"><i class="bi bi-clock"></i> Not yet</span>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="empty-state" style="padding:20px 16px">
                    <i class="bi bi-calendar-check" style="font-size:1.8rem"></i>
                    <div style="font-weight:700;color:#555;margin-bottom:4px">No more trips today</div>
                    <div style="font-size:.78rem">All scheduled buses for today have been shown above</div>
                </div>
            </c:otherwise>
        </c:choose>

    </div>
</div>

<script>
const CTX_DASH = '${pageContext.request.contextPath}';
let sheetState = 'partial'; // partial | expanded | collapsed
let notifOpen = false;
let dashNotifs = [];

// -- GREETING --
(function() {
    const h = new Date().getHours();
    const g = h < 12 ? 'morning' : h < 17 ? 'afternoon' : 'evening';
    document.getElementById('time-greeting').textContent = g;
})();

// -- LAST UPDATED TICKER --
let lastRefreshTime = Date.now();
function updateLastRefreshLabel() {
    const el = document.getElementById('last-updated');
    if (!el) return;
    const secs = Math.floor((Date.now() - lastRefreshTime) / 1000);
    el.textContent = secs < 10 ? 'Updated just now' : 'Updated ' + secs + 's ago';
}
setInterval(updateLastRefreshLabel, 5000);

// -- MAP --
let map, busMarkers = [];
window.initMap = function() {
    const defaultCenter = { lat: -25.7313, lng: 28.1648 };
    map = new google.maps.Map(document.getElementById('map'), {
        center: defaultCenter,
        zoom: 13,
        disableDefaultUI: false,
        zoomControl: true,
        gestureHandling: 'cooperative',
        mapTypeId: 'roadmap',
        styles: [
            { featureType: 'poi', elementType: 'labels', stylers: [{ visibility: 'off' }] },
            { featureType: 'transit.station.bus', stylers: [{ visibility: 'off' }] }
        ]
    });
    navigator.geolocation && navigator.geolocation.getCurrentPosition(
        p => map.setCenter({ lat: p.coords.latitude, lng: p.coords.longitude }),
        () => {}
    );
    // Drop live bus markers on map
    const busIconSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20"><circle cx="10" cy="10" r="8" fill="#00c853" stroke="white" stroke-width="3"/></svg>`;
    const busGmIcon = {
        url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(busIconSvg),
        scaledSize: new google.maps.Size(20, 20),
        anchor: new google.maps.Point(10, 10)
    };
    const liveTrips = [];
    <c:forEach var="t" items="${activeTrips}">liveTrips.push({ id: ${t.tripId}, name: "${t.route.routeName}", driver: "${t.driver.name}" });</c:forEach>
    liveTrips.forEach(t => {
        fetch(CTX_DASH + '/tracking/latest?tripId=' + t.id).then(r => r.json()).then(d => {
            if (d && d.lat && d.lng) {
                const m = new google.maps.Marker({
                    position: { lat: d.lat, lng: d.lng },
                    map: map,
                    icon: busGmIcon,
                    title: t.name
                });
                const iw = new google.maps.InfoWindow({ content: '<b>' + t.name + '</b><br>Driver: ' + t.driver });
                m.addListener('click', () => iw.open(map, m));
                busMarkers.push(m);
                if (liveTrips.length === 1) map.setCenter({ lat: d.lat, lng: d.lng });
            }
        }).catch(() => {});
    });
}

// -- SHEET --
function applyPassState(state) {
    const sheet = document.getElementById('bottom-sheet');
    const hint  = document.getElementById('sheet-hint');
    sheetState = state;
    sheet.style.transition = '';
    if (state === 'expanded') {
        sheet.classList.add('expanded'); sheet.classList.remove('collapsed');
        hint.textContent = 'DRAG DOWN TO SEE MAP';
    } else if (state === 'collapsed') {
        sheet.classList.add('collapsed'); sheet.classList.remove('expanded');
        hint.textContent = 'DRAG UP FOR TRIPS';
    } else {
        sheet.classList.remove('collapsed', 'expanded');
        hint.textContent = 'DRAG UP FOR MORE';
    }
}
function toggleSheet() {
    if (sheetState === 'partial') applyPassState('expanded');
    else if (sheetState === 'expanded') applyPassState('collapsed');
    else applyPassState('partial');
}
(function() {
    const handle = document.getElementById('pass-handle');
    const sheet  = document.getElementById('bottom-sheet');
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
        const newH = Math.max(52, Math.min(window.innerHeight * 0.88, startH + diff));
        sheet.style.height = newH + 'px';
    }
    function onEnd() {
        if (!dragging) return;
        dragging = false;
        if (movedPx > 8) {
            const h = sheet.getBoundingClientRect().height;
            const vh = window.innerHeight;
            if (h < vh * 0.2)        applyPassState('collapsed');
            else if (h > vh * 0.55)  applyPassState('expanded');
            else                      applyPassState('partial');
            sheet.style.height = '';
        }
        // if movedPx <= 8 it was a tap; click event will fire and call toggleSheet
    }
    handle.addEventListener('touchstart', onStart, { passive: true });
    handle.addEventListener('touchmove',  onMove,  { passive: false });
    handle.addEventListener('touchend',   onEnd);
    handle.addEventListener('mousedown',  onStart);
    document.addEventListener('mousemove', onMove);
    document.addEventListener('mouseup',   onEnd);
    handle.addEventListener('click', function() {
        if (movedPx > 8) return; // was a drag, not a tap
        toggleSheet();
    });
})();

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
            const icon = n.type === 'DELAY'
              ? '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="#f59e0b"><path d="M12 2a1 1 0 0 1 .894.553l9 18A1 1 0 0 1 21 22H3a1 1 0 0 1-.894-1.447l9-18A1 1 0 0 1 12 2zm0 3.236L4.118 20h15.764L12 5.236zM11 10v4a1 1 0 1 0 2 0v-4a1 1 0 1 0-2 0zm1 7a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/></svg>'
              : '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="#3b82f6"><path d="M18 4a1 1 0 0 1 .948.684l.025.09.027.226V14a1 1 0 0 1-.684.948l-.09.025L18 15H7l-2 3H4V7l2-3h12zm-1 2H7.5L6 8.5V16h1l2-3h8V6zm-9 3h8v2H8V9zm0 4h5v2H8v-2z"/></svg>';
            const label = n.type === 'DELAY' ? 'Delay Alert' : 'Announcement';
            return '<div class="notif-item' + (n.type==='DELAY'?' delay':'') + '">'
                + '<div style="display:flex;align-items:center">' + icon + '</div>'
                + '<div class="notif-msg"><b style="font-size:.72rem;text-transform:uppercase;letter-spacing:.5px;color:#f59e0b">' + label + '</b><br>' + d.innerHTML + '<div class="notif-time">' + n.time + '</div></div></div>';
        }).join('');
        document.getElementById('notif-badge').textContent = notifs.length;
        document.getElementById('notif-badge').classList.add('visible');
    }).catch(() => {});
}
setInterval(pollNotifs, 15000);
pollNotifs();

// ── Nearest terminal recommendation ──────────────────────────────────
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
                if (!stops || !stops.length) {
                    setRec('out-of-range', 'exclamation-triangle-fill',
                        'No stops found', 'No bus stops are registered in the system yet.');
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
                    'Check your connection and try refreshing');
            });
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
})()
})();

// ── Auto-refresh: swap trip cards (Live Now + Upcoming) every 10s ──
(function() {
    const busMarkers = [];

    // Track which trip IDs were live on the last refresh
    let knownLiveIds = new Set(
        Array.from(document.querySelectorAll('[data-live-trip]'))
             .map(el => el.getAttribute('data-live-trip'))
    );

    function vibrateDevice() {
        if ('vibrate' in navigator) {
            // Two short pulses: buzz-pause-buzz
            navigator.vibrate([200, 100, 200]);
        }
    }

    async function autoRefreshPassenger() {
        try {
            const res = await fetch(location.href, { credentials: 'same-origin' });
            if (!res.ok) return;
            const doc = new DOMParser().parseFromString(await res.text(), 'text/html');
            const fresh = doc.getElementById('pass-sheet-content');
            const curr  = document.getElementById('pass-sheet-content');
            if (fresh && curr) curr.outerHTML = fresh.outerHTML;
            lastRefreshTime = Date.now();
            updateLastRefreshLabel();

            // Check for newly started trips → vibrate
            const freshLiveIds = new Set(
                Array.from(doc.querySelectorAll('[data-live-trip]'))
                     .map(el => el.getAttribute('data-live-trip'))
            );
            const newlyStarted = [...freshLiveIds].filter(id => !knownLiveIds.has(id));
            if (newlyStarted.length > 0) {
                vibrateDevice();
            }
            knownLiveIds = freshLiveIds;
            // refresh bus markers on map
            busMarkers.forEach(m => m.setMap(null));
            busMarkers.length = 0;
            const busIconSvg2 = `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20"><circle cx="10" cy="10" r="8" fill="#00c853" stroke="white" stroke-width="3"/></svg>`;
            const busGmIcon2 = map ? {
                url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(busIconSvg2),
                scaledSize: new google.maps.Size(20, 20),
                anchor: new google.maps.Point(10, 10)
            } : null;
            doc.querySelectorAll('[data-live-trip]').forEach(el => {
                const tid = el.getAttribute('data-live-trip');
                const name = el.getAttribute('data-trip-name') || '';
                const driver = el.getAttribute('data-driver') || '';
                fetch(CTX_DASH + '/tracking/latest?tripId=' + tid).then(r => r.json()).then(d => {
                    if (d && d.lat && d.lng && map) {
                        const m = new google.maps.Marker({
                            position: { lat: d.lat, lng: d.lng }, map: map,
                            icon: busGmIcon2, title: name
                        });
                        busMarkers.push(m);
                    }
                }).catch(() => {});
            });
        } catch (e) { /* silent */ }
    }
    setInterval(autoRefreshPassenger, 10000);

    // ── Offline cache: save trip data to localStorage ──
    const CACHE_KEY = 'commutesafe_cached_trips';
    (function initOfflineCache() {
        if (!navigator.onLine) {
            try {
                const cached = JSON.parse(localStorage.getItem(CACHE_KEY) || '{}');
                if (cached.ts && (Date.now() - cached.ts) < 3600000) {
                    const banner = document.createElement('div');
                    banner.style.cssText = 'position:fixed;top:0;left:0;right:0;z-index:9999;background:#f59e0b;color:#000;text-align:center;padding:8px;font-size:.82rem;font-weight:700';
                    banner.textContent = '\u26a1 Offline \u2014 showing cached data from ' + new Date(cached.ts).toLocaleTimeString();
                    document.body.prepend(banner);
                }
            } catch(e) {}
        } else {
            // Save current trip data to cache
            try {
                const liveCards = document.querySelectorAll('[data-live-trip]');
                const liveIds = Array.from(liveCards).map(el => ({
                    tripId: el.getAttribute('data-live-trip'),
                    name:   el.getAttribute('data-trip-name') || ''
                }));
                localStorage.setItem(CACHE_KEY, JSON.stringify({ ts: Date.now(), live: liveIds }));
            } catch(e) {}
        }
    })();
})();

<% if (firebaseReady) { %>
// ── Firebase Cloud Messaging (push notifications) ─────────────────────────
(function initFCM() {
    if (!('Notification' in window) || !('serviceWorker' in navigator)) return;
    const firebaseConfig = {
        apiKey:            '<%= fbApiKey %>',
        authDomain:        '<%= fbAuthDomain %>',
        projectId:         '<%= fbProjectId %>',
        messagingSenderId: '<%= fbMsgSenderId %>',
        appId:             '<%= fbAppId %>'
    };
    // Load Firebase compat SDK
    const sdkBase = 'https://www.gstatic.com/firebasejs/10.12.0/firebase-';
    Promise.all([
        loadScript(sdkBase + 'app-compat.js'),
        loadScript(sdkBase + 'messaging-compat.js')
    ]).then(() => {
        if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
        const messaging = firebase.messaging();
        return navigator.serviceWorker.register('<c:url value="/firebase-messaging-sw.js"/>')
            .then(reg => messaging.getToken({ vapidKey: '<%= fbVapidKey %>', serviceWorkerRegistration: reg }))
            .then(token => {
                if (!token) return;
                return fetch('<c:url value="/fcm/token"/>', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'token=' + encodeURIComponent(token)
                });
            });
    }).catch(() => {});
    function loadScript(src) {
        return new Promise((res, rej) => {
            const s = document.createElement('script');
            s.src = src; s.onload = res; s.onerror = rej;
            document.head.appendChild(s);
        });
    }
})();
<% } %>
</script>
<% if (!mapsKey.isEmpty()) { %>
<script src="https://maps.googleapis.com/maps/api/js?key=<%= mapsKey %>&callback=initMap" async defer></script>
<% } else { %>
<script>window.addEventListener('DOMContentLoaded',function(){document.getElementById('map').innerHTML='<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#64748b;font-size:.85rem">Set GOOGLE_MAPS_KEY to enable map</div>';});</script>
<% } %>
</body>
</html>
