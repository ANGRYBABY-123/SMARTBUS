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
    <meta charset="UTF-8">
    <title>Auto-Generate Trips – CommuteSafe</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>#route-preview-map{ height:200px; border-radius:10px; border:1px solid #dee2e6; overflow:hidden; margin-top:.75rem; display:none; }</style>
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container sb-main" style="max-width:580px">
    <div class="mb-3">
        <a href="${pageContext.request.contextPath}/trips/list"
           style="color:#64748b;text-decoration:none;font-size:.82rem">
            <i class="bi bi-arrow-left me-1"></i>Back to Trips
        </a>
    </div>
    <h5 class="fw-bold mb-1">
        <i class="bi bi-lightning-charge-fill me-2" style="color:#f59e0b"></i>Auto-Generate Hourly Trips
    </h5>
    <p style="color:#64748b;font-size:.85rem;margin-bottom:1.5rem">
        Creates one <strong>SCHEDULED</strong> trip per hour from the start time up to (but not including) 5 PM.
    </p>

    <div class="card p-4">
        <form method="post" action="${pageContext.request.contextPath}/trips/autogenerate" novalidate>

            <div class="mb-3">
                <label class="form-label">Driver</label>
                <select name="driverId" class="form-select" required>
                    <option value="">-- Select Driver --</option>
                    <c:forEach var="d" items="${drivers}">
                        <option value="${d.userId}">${d.name}</option>
                    </c:forEach>
                </select>
                <c:if test="${empty drivers}">
                    <div style="color:#f87171;font-size:.76rem;margin-top:.3rem">
                        <i class="bi bi-exclamation-triangle me-1"></i>No drivers found.
                    </div>
                </c:if>
            </div>

            <div class="mb-3">
                <label class="form-label">Vehicle</label>
                <select name="busId" class="form-select" required>
                    <option value="">-- Select Vehicle --</option>
                    <c:forEach var="b" items="${buses}">
                        <option value="${b.busId}">${b.registrationNumber} &nbsp;(${b.capacity} seats)</option>
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
                            data-name="${r.routeName}">
                            ${r.routeName} &nbsp;(${r.startLocation} &rarr; ${r.endLocation})</option>
                    </c:forEach>
                </select>
                <div id="route-preview-map"></div>
            </div>

            <div class="mb-3">
                <label class="form-label">Date</label>
                <input type="date" name="tripDate" id="tripDate" class="form-control" required>
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label">Start Hour</label>
                    <select name="startHour" id="startHour" class="form-select" required>
                        <c:forEach begin="0" end="16" var="h">
                            <option value="${h}" ${h == 6 ? 'selected' : ''}>
                                <c:choose>
                                    <c:when test="${h == 0}">12:00 AM</c:when>
                                    <c:when test="${h < 12}">${h}:00 AM</c:when>
                                    <c:when test="${h == 12}">12:00 PM</c:when>
                                    <c:otherwise>${h - 12}:00 PM</c:otherwise>
                                </c:choose>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-6 mb-3">
                    <label class="form-label">End Hour <small style="color:#94a3b8">(max 5:00 PM)</small></label>
                    <select name="endHour" id="endHour" class="form-select" required>
                        <c:forEach begin="1" end="17" var="h">
                            <option value="${h}" ${h == 17 ? 'selected' : ''}>
                                <c:choose>
                                    <c:when test="${h < 12}">${h}:00 AM</c:when>
                                    <c:when test="${h == 12}">12:00 PM</c:when>
                                    <c:otherwise>${h - 12}:00 PM</c:otherwise>
                                </c:choose>
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div id="preview-box" class="alert alert-info" style="font-size:.83rem;display:none">
                <i class="bi bi-info-circle me-1"></i>
                <span id="preview-text"></span>
            </div>

            <hr>
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-warning px-4 fw-bold">
                    <i class="bi bi-lightning-charge-fill me-1"></i>Generate Trips
                </button>
                <a href="${pageContext.request.contextPath}/trips/list"
                   class="btn btn-outline-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>

<script>
var routePreviewMap = null, rpOrigin = null, rpDest = null, rpLine = null;

window.initMap = function() {};

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
        routePreviewMap = new google.maps.Map(mapDiv, {
            center: { lat: sLat, lng: sLng }, zoom: 11,
            mapTypeId: 'roadmap', gestureHandling: 'cooperative',
            styles: [
                { featureType:'poi', elementType:'labels', stylers:[{ visibility:'off' }] },
                { featureType:'transit.station.bus', stylers:[{ visibility:'off' }] }
            ]
        });
    }
    if (rpOrigin) { rpOrigin.setMap(null); rpOrigin = null; }
    if (rpDest)   { rpDest.setMap(null);   rpDest   = null; }
    if (rpLine)   { rpLine.setMap(null);   rpLine   = null; }
    rpOrigin = new google.maps.Marker({
        position:{ lat:sLat, lng:sLng }, map:routePreviewMap, title: opt.dataset.name + ' – Start',
        icon:{ path:google.maps.SymbolPath.CIRCLE, scale:8, fillColor:'#22c55e', fillOpacity:1, strokeColor:'#fff', strokeWeight:2 }
    });
    rpDest = new google.maps.Marker({
        position:{ lat:eLat, lng:eLng }, map:routePreviewMap, title: opt.dataset.name + ' – End',
        icon:{ path:google.maps.SymbolPath.CIRCLE, scale:8, fillColor:'#ef4444', fillOpacity:1, strokeColor:'#fff', strokeWeight:2 }
    });
    rpLine = new google.maps.Polyline({
        path:[{ lat:sLat, lng:sLng },{ lat:eLat, lng:eLng }],
        map:routePreviewMap, strokeColor:'#3b82f6', strokeWeight:3, strokeOpacity:0.85
    });
    var bounds = new google.maps.LatLngBounds();
    bounds.extend({ lat:sLat, lng:sLng }); bounds.extend({ lat:eLat, lng:eLng });
    routePreviewMap.fitBounds(bounds, 30);
}
</script>
<% if (!mapsKey.isEmpty()) { %>
<script src="https://maps.googleapis.com/maps/api/js?key=<%= mapsKey %>&callback=initMap&loading=async" defer></script>
<% } %>
<script>
    // Default date = today
    (function () {
        var now = new Date();
        var pad = function(n){ return n < 10 ? '0' + n : n; };
        document.getElementById('tripDate').value =
            now.getFullYear() + '-' + pad(now.getMonth()+1) + '-' + pad(now.getDate());
    })();

    // Live preview of how many trips will be created
    function updatePreview() {
        var start = parseInt(document.getElementById('startHour').value, 10);
        var end   = parseInt(document.getElementById('endHour').value, 10);
        var box   = document.getElementById('preview-box');
        var txt   = document.getElementById('preview-text');
        if (end > start) {
            var count = end - start;
            txt.textContent = count + ' trip' + (count > 1 ? 's' : '') +
                ' will be created (one per hour from ' + fmtHour(start) + ' to ' + fmtHour(end) + ').';
            box.style.display = '';
        } else {
            box.style.display = 'none';
        }
    }
    function fmtHour(h) {
        if (h === 0) return '12:00 AM';
        if (h < 12) return h + ':00 AM';
        if (h === 12) return '12:00 PM';
        return (h - 12) + ':00 PM';
    }
    document.getElementById('startHour').addEventListener('change', updatePreview);
    document.getElementById('endHour').addEventListener('change', updatePreview);
    updatePreview();
</script>
</body>
</html>
