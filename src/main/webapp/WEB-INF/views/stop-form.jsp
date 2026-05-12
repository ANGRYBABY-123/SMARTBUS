<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><title>${empty stop ? 'Add Stop' : 'Edit Stop'} – CommuteSafe</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
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

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
const latInput = document.getElementById('lat-input');
const lngInput = document.getElementById('lng-input');

const initLat = parseFloat(latInput.value) || -25.5275;
const initLng = parseFloat(lngInput.value) || 28.0952;

const map = L.map('pick-map').setView([initLat, initLng], 13);
L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', { maxZoom: 19 }).addTo(map);

let marker = null;
if (latInput.value && lngInput.value) {
    marker = L.marker([initLat, initLng], { draggable: true }).addTo(map);
    marker.on('dragend', function() {
        const p = marker.getLatLng();
        latInput.value = p.lat.toFixed(6);
        lngInput.value = p.lng.toFixed(6);
    });
}

map.on('click', function(e) {
    latInput.value = e.latlng.lat.toFixed(6);
    lngInput.value = e.latlng.lng.toFixed(6);
    if (marker) { marker.setLatLng(e.latlng); }
    else { marker = L.marker(e.latlng, { draggable: true }).addTo(map);
        marker.on('dragend', function() {
            const p = marker.getLatLng();
            latInput.value = p.lat.toFixed(6);
            lngInput.value = p.lng.toFixed(6);
        });
    }
});

// Sync map if coords typed manually
[latInput, lngInput].forEach(el => el.addEventListener('change', function() {
    const lat = parseFloat(latInput.value), lng = parseFloat(lngInput.value);
    if (!isNaN(lat) && !isNaN(lng)) {
        map.setView([lat, lng], 14);
        if (marker) marker.setLatLng([lat, lng]);
        else { marker = L.marker([lat, lng], { draggable: true }).addTo(map); }
    }
}));
</script>
</body>
</html>
