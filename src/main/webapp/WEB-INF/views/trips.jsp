<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String mapsKey = getServletContext().getInitParameter("google.maps.key");
    if (mapsKey == null || mapsKey.isBlank() || "YOUR_GOOGLE_MAPS_API_KEY".equals(mapsKey))
        mapsKey = System.getenv("GOOGLE_MAPS_KEY") != null ? System.getenv("GOOGLE_MAPS_KEY") : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><title>Trips – CommuteSafe</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
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

window.initMap = function() {
    tripsMap = new google.maps.Map(document.getElementById('trips-map'), {
        center: { lat: -25.65, lng: 28.09 },
        zoom: 10,
        mapTypeId: 'roadmap',
        gestureHandling: 'cooperative',
        disableDefaultUI: false,
        styles: [
            { featureType:'poi', elementType:'labels', stylers:[{ visibility:'off' }] },
            { featureType:'transit.station.bus', stylers:[{ visibility:'off' }] }
        ]
    });
    // Plot all routes as faint polylines on load
    var bounds = new google.maps.LatLngBounds();
    var hasPoints = false;
    document.querySelectorAll('.trip-row-clickable').forEach(function(row) {
        var sLat = parseFloat(row.dataset.slat), sLng = parseFloat(row.dataset.slng);
        var eLat = parseFloat(row.dataset.elat), eLng = parseFloat(row.dataset.elng);
        var status = row.dataset.status;
        var color = STATUS_COLORS[status] || '#94a3b8';
        if (!isNaN(sLat) && !isNaN(sLng) && !isNaN(eLat) && !isNaN(eLng)) {
            new google.maps.Polyline({
                path: [{ lat: sLat, lng: sLng }, { lat: eLat, lng: eLng }],
                map: tripsMap, strokeColor: color, strokeWeight: 2, strokeOpacity: 0.35
            });
            bounds.extend({ lat: sLat, lng: sLng });
            bounds.extend({ lat: eLat, lng: eLng });
            hasPoints = true;
        }
    });
    if (hasPoints) tripsMap.fitBounds(bounds, 40);
};

function clearActive() {
    if (activePolyline) { activePolyline.setMap(null); activePolyline = null; }
    activeMarkers.forEach(function(m){ m.setMap(null); }); activeMarkers = [];
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
    activePolyline = new google.maps.Polyline({
        path: [{ lat: sLat, lng: sLng }, { lat: eLat, lng: eLng }],
        map: tripsMap, strokeColor: color, strokeWeight: 4, strokeOpacity: 1
    });
    var mkStart = new google.maps.Marker({
        position:{ lat:sLat, lng:sLng }, map:tripsMap, title: row.dataset.route + ' – Start',
        icon:{ path:google.maps.SymbolPath.CIRCLE, scale:8, fillColor:'#22c55e', fillOpacity:1, strokeColor:'#fff', strokeWeight:2 }
    });
    var mkEnd = new google.maps.Marker({
        position:{ lat:eLat, lng:eLng }, map:tripsMap, title: row.dataset.route + ' – End',
        icon:{ path:google.maps.SymbolPath.CIRCLE, scale:8, fillColor:color, fillOpacity:1, strokeColor:'#fff', strokeWeight:2 }
    });
    activeMarkers.push(mkStart, mkEnd);
    var bounds = new google.maps.LatLngBounds();
    bounds.extend({ lat:sLat, lng:sLng }); bounds.extend({ lat:eLat, lng:eLng });
    tripsMap.fitBounds(bounds, 60);
}
</script>
<% if (!mapsKey.isEmpty()) { %>
<script src="https://maps.googleapis.com/maps/api/js?key=<%= mapsKey %>&callback=initMap" async defer></script>
<% } else { %>
<script>window.addEventListener('DOMContentLoaded',function(){
    document.getElementById('trips-map').innerHTML='<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#64748b;font-size:.85rem"><i class="bi bi-map me-2"></i>Set GOOGLE_MAPS_KEY to enable route overview</div>';
});</script>
<% } %>
</body>
</html>