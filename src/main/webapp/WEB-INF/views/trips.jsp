<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><title>Trips – CommuteSafe</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin=""/>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
    <style>
        #trips-map { height:280px; border-radius:10px; border:1px solid #dee2e6; overflow:hidden; margin-bottom:1.25rem; }
        .trip-row-clickable { cursor:pointer; }
        .trip-row-clickable:hover { background:#f0f9ff; }
        .trip-row-clickable.active-row { background:#dbeafe; }
    </style>
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container-fluid sb-main">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h5 class="fw-bold mb-0">
                <i class="bi bi-signpost-split-fill me-2" style="color:#3b82f6"></i>Trips
            </h5>
            <small style="color:#64748b">Auto-generated when a Weekly Schedule is published.</small>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/trips/autogenerate" class="btn btn-warning btn-sm fw-bold">
                <i class="bi bi-lightning-charge-fill me-1"></i>Auto-Generate Hourly
            </a>
            <a href="${pageContext.request.contextPath}/weekly-schedule/list" class="btn btn-primary btn-sm">
                <i class="bi bi-calendar-week me-1"></i>Manage Weekly Schedule
            </a>
        </div>
    </div>
    <form class="d-flex gap-2 mb-3" method="get" action="${pageContext.request.contextPath}/trips/list">
        <select name="status" class="form-select form-select-sm" style="max-width:210px">
            <option value="">All Statuses</option>
            <option value="SCHEDULED">Scheduled</option>
            <option value="IN_PROGRESS">In Progress</option>
            <option value="COMPLETED">Completed</option>
            <option value="CANCELLED">Cancelled</option>
        </select>
        <button class="btn btn-sm btn-outline-secondary"><i class="bi bi-funnel me-1"></i>Filter</button>
    </form>
    <div id="trips-map"></div>
    <div class="card">
        <table class="table table-hover mb-0">
            <thead>
                <tr>
                    <th>#</th><th>Driver</th><th>Bus</th>
                    <th>Route</th><th>Scheduled Start</th><th>Status</th><th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <c:forEach var="t" items="${trips}">
                <tr class="trip-row-clickable" data-trip-id="${t.tripId}"
                    data-slat="${t.route.startLat}" data-slng="${t.route.startLng}"
                    data-elat="${t.route.endLat}"  data-elng="${t.route.endLng}"
                    data-route="${t.route.routeName}" data-status="${t.status}"
                    onclick="focusTrip(this)">
                    <td style="color:#64748b;font-size:.8rem">${t.tripId}</td>
                    <td style="font-weight:500">${t.driver.name}</td>
                    <td><span style="font-family:monospace;color:#93c5fd">${t.bus.registrationNumber}</span></td>
                    <td>${t.route.routeName}</td>
                    <td style="color:#94a3b8;font-size:.83rem">${t.startTime}</td>
                    <td>
                        <c:choose>
                            <c:when test="${t.status=='IN_PROGRESS'}"><span class="badge bg-success">In Progress</span></c:when>
                            <c:when test="${t.status=='COMPLETED'}"><span class="badge bg-secondary">Completed</span></c:when>
                            <c:when test="${t.status=='CANCELLED'}"><span class="badge bg-danger">Cancelled</span></c:when>
                            <c:otherwise><span class="badge bg-primary">Scheduled</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:if test="${t.status=='IN_PROGRESS'}">
                            <a href="${pageContext.request.contextPath}/tracking/view?tripId=${t.tripId}"
                               class="btn btn-sm btn-success" target="_blank" title="Live GPS Tracking">
                                <i class="bi bi-geo-alt-fill"></i> Track
                            </a>
                        </c:if>
                        <a href="${pageContext.request.contextPath}/trips/delete?id=${t.tripId}"
                           class="btn btn-sm btn-outline-danger" title="Delete"
                           onclick="return confirm('Delete trip #${t.tripId}?')"><i class="bi bi-trash"></i></a>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty trips}">
                <tr><td colspan="7" class="text-center py-4" style="color:#64748b">No trips found. <a href="${pageContext.request.contextPath}/weekly-schedule/list" style="color:#3b82f6">Publish a weekly schedule</a> to auto-generate trips.</td></tr>
            </c:if>
            </tbody>
        </table>
    </div>
</div>

<script>
var tripsMap, activePolyline = null, activeMarkers = [];
var STATUS_COLORS = { IN_PROGRESS: '#16a34a', SCHEDULED: '#3b82f6', COMPLETED: '#94a3b8', CANCELLED: '#ef4444' };

function initMap() {
    tripsMap = L.map('trips-map', { center: [-25.65, 28.09], zoom: 10, zoomControl: true });
    L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; <a href="https://carto.com/attributions">CARTO</a>',
        maxZoom: 20, subdomains: 'abcd'
    }).addTo(tripsMap);
    var bounds = L.latLngBounds();
    var hasPoints = false;
    document.querySelectorAll('.trip-row-clickable').forEach(function(row) {
        var sLat = parseFloat(row.dataset.slat), sLng = parseFloat(row.dataset.slng);
        var eLat = parseFloat(row.dataset.elat), eLng = parseFloat(row.dataset.elng);
        var status = row.dataset.status;
        var color = STATUS_COLORS[status] || '#94a3b8';
        if (!isNaN(sLat) && !isNaN(sLng) && !isNaN(eLat) && !isNaN(eLng)) {
            L.polyline([[sLat, sLng], [eLat, eLng]], {
                color: color, weight: 2, opacity: 0.35
            }).addTo(tripsMap);
            bounds.extend([sLat, sLng]);
            bounds.extend([eLat, eLng]);
            hasPoints = true;
        }
    });
    if (hasPoints) tripsMap.fitBounds(bounds, {padding: [40, 40]});
}

function clearActive() {
    if (activePolyline) { activePolyline.remove(); activePolyline = null; }
    activeMarkers.forEach(function(m){ m.remove(); }); activeMarkers = [];
    document.querySelectorAll('.active-row').forEach(function(r){ r.classList.remove('active-row'); });
}

function focusTrip(row) {
    clearActive();
    row.classList.add('active-row');
    var sLat = parseFloat(row.dataset.slat), sLng = parseFloat(row.dataset.slng);
    var eLat = parseFloat(row.dataset.elat), eLng = parseFloat(row.dataset.elng);
    var status = row.dataset.status;
    var color = STATUS_COLORS[status] || '#3b82f6';
    if (!tripsMap || isNaN(sLat) || isNaN(eLat)) return;
    activePolyline = L.polyline([[sLat, sLng], [eLat, eLng]], {
        color: color, weight: 4, opacity: 1
    }).addTo(tripsMap);
    var mkStart = L.circleMarker([sLat, sLng], {
        radius: 8, fillColor: '#22c55e', fillOpacity: 1, color: '#fff', weight: 2
    }).addTo(tripsMap);
    var mkEnd = L.circleMarker([eLat, eLng], {
        radius: 8, fillColor: color, fillOpacity: 1, color: '#fff', weight: 2
    }).addTo(tripsMap);
    activeMarkers.push(mkStart, mkEnd);
    tripsMap.fitBounds(L.latLngBounds([[sLat, sLng], [eLat, eLng]]), {padding: [60, 60]});
}

window.addEventListener('DOMContentLoaded', initMap);
</script>
</body>
</html>