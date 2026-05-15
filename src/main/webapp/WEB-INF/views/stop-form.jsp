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
    <meta charset="UTF-8"><title>${empty stop ? 'Add Stop' : 'Edit Stop'} – CommuteSafe</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        #pick-map { height: 300px; border-radius: 12px; border: 1.5px solid var(--sb-border); overflow: hidden; margin-bottom: 10px; cursor: crosshair; }
        #pick-hint { font-size: .78rem; color: var(--sb-muted); margin-bottom: 14px; }
    </style>
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container-fluid sb-main" style="max-width:680px">
    <div class="d-flex align-items-center gap-2 mb-4">
        <a href="${pageContext.request.contextPath}/stops/list" class="btn btn-sm btn-outline-secondary">
            <i class="bi bi-arrow-left"></i>
        </a>
        <h5 class="fw-bold mb-0">
            <i class="bi bi-pin-map-fill me-2" style="color:#3b82f6"></i>
            ${empty stop ? 'Add Bus Stop' : 'Edit Bus Stop'}
        </h5>
    </div>

    <div class="card p-4">
        <form method="post" action="${pageContext.request.contextPath}/stops/save">
            <c:if test="${not empty stop}">
                <input type="hidden" name="stopId" value="${stop.stopId}">
            </c:if>

            <div class="mb-3">
                <label class="form-label">Stop Name</label>
                <input type="text" name="name" class="form-control" required
                       placeholder="e.g. Soshanguve North Terminal"
                       value="${not empty stop ? stop.name : ''}">
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <label class="form-label">Latitude</label>
                    <input type="number" step="any" name="latitude" id="lat-input" class="form-control"
                           placeholder="e.g. -25.5275"
                           value="${not empty stop and stop.latitude != null ? stop.latitude : ''}">
                </div>
                <div class="col-md-6">
                    <label class="form-label">Longitude</label>
                    <input type="number" step="any" name="longitude" id="lng-input" class="form-control"
                           placeholder="e.g. 28.0952"
                           value="${not empty stop and stop.longitude != null ? stop.longitude : ''}">
                </div>
            </div>

            <!-- Map picker -->
            <div id="pick-hint">
                <i class="bi bi-cursor-fill me-1"></i>
                Click on the map to set coordinates — or type them manually above.
            </div>
            <div id="pick-map"></div>

            <div class="mb-4">
                <label class="form-label">Routes Served at This Stop</label>
                <div style="background:var(--sb-elevated);border:1px solid var(--sb-border);border-radius:10px;padding:14px;display:flex;flex-wrap:wrap;gap:10px;">
                    <c:forEach var="r" items="${allRoutes}">
                        <label style="display:flex;align-items:center;gap:6px;cursor:pointer;font-size:.85rem;color:var(--sb-text);">
                            <input type="checkbox" name="routeIds" value="${r.routeId}"
                                   style="accent-color:#3b82f6;"
                                   <c:if test="${not empty stop}">
                                       <c:forEach var="sr" items="${stop.routes}">
                                           <c:if test="${sr.routeId == r.routeId}">checked</c:if>
                                       </c:forEach>
                                   </c:if>
                            >
                            ${r.routeName}
                        </label>
                    </c:forEach>
                    <c:if test="${empty allRoutes}">
                        <span style="color:var(--sb-muted);font-size:.83rem">No routes defined yet — add routes first.</span>
                    </c:if>
                </div>
            </div>

            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-check-lg me-1"></i>${empty stop ? 'Add Stop' : 'Save Changes'}
                </button>
                <a href="${pageContext.request.contextPath}/stops/list" class="btn btn-outline-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>

<script>
const latInput = document.getElementById('lat-input');
const lngInput = document.getElementById('lng-input');
const initLat = parseFloat(latInput.value) || -25.5275;
const initLng = parseFloat(lngInput.value) || 28.0952;
let pickMap, pickMarker = null;

window.initPickMap = function() {
    pickMap = new google.maps.Map(document.getElementById('pick-map'), {
        center: { lat: initLat, lng: initLng },
        zoom: 13,
        gestureHandling: 'cooperative',
        mapTypeId: 'roadmap',
        styles: [
            { featureType: 'poi', elementType: 'labels', stylers: [{ visibility: 'off' }] },
            { featureType: 'transit.station.bus', stylers: [{ visibility: 'off' }] }
        ]
    });
    if (latInput.value && lngInput.value) {
        pickMarker = new google.maps.Marker({ position: { lat: initLat, lng: initLng }, map: pickMap, draggable: true });
        pickMarker.addListener('dragend', function() {
            latInput.value = pickMarker.getPosition().lat().toFixed(6);
            lngInput.value = pickMarker.getPosition().lng().toFixed(6);
        });
    }
    pickMap.addListener('click', function(e) {
        latInput.value = e.latLng.lat().toFixed(6);
        lngInput.value = e.latLng.lng().toFixed(6);
        if (pickMarker) {
            pickMarker.setPosition(e.latLng);
        } else {
            pickMarker = new google.maps.Marker({ position: e.latLng, map: pickMap, draggable: true });
            pickMarker.addListener('dragend', function() {
                latInput.value = pickMarker.getPosition().lat().toFixed(6);
                lngInput.value = pickMarker.getPosition().lng().toFixed(6);
            });
        }
    });
    [latInput, lngInput].forEach(el => el.addEventListener('change', function() {
        const lat = parseFloat(latInput.value), lng = parseFloat(lngInput.value);
        if (!isNaN(lat) && !isNaN(lng)) {
            const pos = { lat, lng };
            pickMap.setCenter(pos); pickMap.setZoom(14);
            if (pickMarker) pickMarker.setPosition(pos);
            else pickMarker = new google.maps.Marker({ position: pos, map: pickMap, draggable: true });
        }
    }));
};
</script>
<% if (!mapsKey.isEmpty()) { %>
<script src="https://maps.googleapis.com/maps/api/js?key=<%= mapsKey %>&callback=initPickMap" async defer></script>
<% } else { %>
<script>window.addEventListener('DOMContentLoaded',function(){document.getElementById('pick-map').innerHTML='<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#64748b;font-size:.85rem">Set GOOGLE_MAPS_KEY to enable map</div>';});</script>
<% } %>
</body>
</html>
