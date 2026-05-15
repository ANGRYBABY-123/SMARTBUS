<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${empty trip ? 'Dispatch Trip' : 'Edit Trip'} – CommuteSafe</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin=""/>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
    <style>#route-preview-map{ height:200px; border-radius:10px; border:1px solid #dee2e6; overflow:hidden; margin-top:.75rem; display:none; }</style>
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container sb-main" style="max-width:580px">
    <div class="mb-3">
        <a href="${pageContext.request.contextPath}/trips/list"
           style="color:#64748b;text-decoration:none;font-size:.82rem">
            <i class="bi bi-arrow-left me-1"></i>Back to Trip Dispatch
        </a>
    </div>
    <h5 class="fw-bold mb-4">
        <i class="bi bi-signpost-split-fill me-2" style="color:#3b82f6"></i>
        ${empty trip ? 'Dispatch New Trip' : 'Edit Trip Record'}
    </h5>
    <div class="card p-4">
        <form method="post" action="${pageContext.request.contextPath}/trips/save" novalidate>
            <input type="hidden" name="tripId" value="${trip.tripId}">

            <div class="mb-3">
                <label class="form-label">Driver</label>
                <select name="driverId" class="form-select" required>
                    <option value="">-- Select Driver --</option>
                    <c:forEach var="d" items="${drivers}">
                        <option value="${d.userId}" ${trip.driver.userId == d.userId ? 'selected' : ''}>
                            ${d.name}
                        </option>
                    </c:forEach>
                </select>
                <c:if test="${empty drivers}">
                    <div style="color:#f87171;font-size:.76rem;margin-top:.3rem">
                        <i class="bi bi-exclamation-triangle me-1"></i>
                        No drivers available. Register users with the "Driver" role first.
                    </div>
                </c:if>
            </div>

            <div class="mb-3">
                <label class="form-label">Vehicle</label>
                <select name="busId" class="form-select" required>
                    <option value="">-- Select Vehicle --</option>
                    <c:forEach var="b" items="${buses}">
                        <option value="${b.busId}" ${trip.bus.busId == b.busId ? 'selected' : ''}>
                            ${b.registrationNumber} &nbsp;(${b.capacity} seats)
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="mb-3">
                <label class="form-label">Route</label>
                <select name="routeId" id="routeId" class="form-select" required onchange="onRouteChange(this.value)">
                    <option value="">-- Select Route --</option>
                    <c:forEach var="r" items="${routes}">
                        <option value="${r.routeId}"
                            data-slat="${r.startLat}" data-slng="${r.startLng}"
                            data-elat="${r.endLat}"  data-elng="${r.endLng}"
                            data-name="${r.routeName}"
                            ${trip.route.routeId == r.routeId ? 'selected' : ''}>
                            ${r.routeName} &nbsp;(${r.startLocation} &rarr; ${r.endLocation})
                        </option>
                    </c:forEach>
                </select>
                <div id="route-preview-map"></div>
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label">Scheduled Departure</label>
                    <input type="datetime-local" name="startTime" id="startTime" class="form-control"
                           value="${trip.startTime}">
                </div>
                <div class="col-md-6 mb-3">
                    <label class="form-label">Actual / Expected Arrival</label>
                    <input type="datetime-local" name="endTime" id="endTime" class="form-control"
                           value="${trip.endTime}">
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label">Trip Status</label>
                <select name="status" class="form-select" required>
                    <option value="SCHEDULED"   ${trip.status=='SCHEDULED'  ?'selected':''}>Scheduled</option>
                    <option value="IN_PROGRESS" ${trip.status=='IN_PROGRESS'?'selected':''}>In Progress</option>
                    <option value="COMPLETED"   ${trip.status=='COMPLETED'  ?'selected':''}>Completed</option>
                    <option value="CANCELLED"   ${trip.status=='CANCELLED'  ?'selected':''}>Cancelled</option>
                </select>
            </div>

            <hr>
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary px-4">
                    <i class="bi bi-check-lg me-1"></i>${empty trip ? 'Dispatch Trip' : 'Save Changes'}
                </button>
                <a href="${pageContext.request.contextPath}/trips/list"
                   class="btn btn-outline-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>
<script>
var routePreviewMap = null, rpOrigin = null, rpDest = null, rpLine = null;

function initMap() {
    var sel = document.getElementById('routeId');
    if (sel && sel.value) onRouteChange(sel.value);
}

function onRouteChange(routeId) {
    var sel = document.getElementById('routeId');
    var opt = sel ? sel.querySelector('option[value="' + routeId + '"]') : null;
    var mapDiv = document.getElementById('route-preview-map');
    if (!opt || !routeId || !mapDiv) return;
    var sLat = parseFloat(opt.dataset.slat), sLng = parseFloat(opt.dataset.slng);
    var eLat = parseFloat(opt.dataset.elat), eLng = parseFloat(opt.dataset.elng);
    if (isNaN(sLat) || isNaN(sLng) || isNaN(eLat) || isNaN(eLng)) {
        mapDiv.style.display = 'none'; return;
    }
    mapDiv.style.display = '';
    if (!routePreviewMap) {
        routePreviewMap = L.map(mapDiv, { center: [sLat, sLng], zoom: 11 });
        L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
            attribution: '&copy; <a href="https://carto.com/attributions">CARTO</a>',
            maxZoom: 20, subdomains: 'abcd'
        }).addTo(routePreviewMap);
    }
    if (rpOrigin) { rpOrigin.remove(); rpOrigin = null; }
    if (rpDest)   { rpDest.remove();   rpDest   = null; }
    if (rpLine)   { rpLine.remove();   rpLine   = null; }
    rpOrigin = L.circleMarker([sLat, sLng], {
        radius: 8, fillColor: '#22c55e', fillOpacity: 1, color: '#fff', weight: 2
    }).addTo(routePreviewMap);
    rpDest = L.circleMarker([eLat, eLng], {
        radius: 8, fillColor: '#ef4444', fillOpacity: 1, color: '#fff', weight: 2
    }).addTo(routePreviewMap);
    rpLine = L.polyline([[sLat, sLng], [eLat, eLng]], {
        color: '#3b82f6', weight: 3, opacity: 0.85
    }).addTo(routePreviewMap);
    routePreviewMap.fitBounds(L.latLngBounds([[sLat, sLng], [eLat, eLng]]), {padding: [30, 30]});
}
window.addEventListener('DOMContentLoaded', initMap);
</script>
<script>
    // For new trips only, prevent selecting past dates
    <c:if test="${empty trip.tripId}">
    (function () {
        var now = new Date();
        var pad = function(n){ return n < 10 ? '0' + n : n; };
        var today = now.getFullYear() + '-' + pad(now.getMonth()+1) + '-' + pad(now.getDate())
                  + 'T' + pad(now.getHours()) + ':' + pad(now.getMinutes());
        var startEl = document.getElementById('startTime');
        var endEl   = document.getElementById('endTime');
        startEl.min = today;
        endEl.min   = today;
        startEl.addEventListener('change', function() {
            if (startEl.value) endEl.min = startEl.value;
        });
    })();
    </c:if>
</script>
</body>
</html>
