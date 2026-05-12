<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${empty route ? 'Add Route' : 'Edit Route'} – CommuteSafe</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
    <style>
        #preview-map { height:220px; border-radius:10px; border:1px solid #dee2e6; overflow:hidden; margin-bottom:1rem; }
        .coord-row { display:flex; gap:8px; }
        .coord-row .form-control { font-family:monospace; font-size:.85rem; }
        .campus-badge { font-size:.72rem; background:#e8f0fe; color:#1a56db; border-radius:4px; padding:1px 5px; }
    </style>
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container sb-main" style="max-width:560px">
    <div class="mb-3">
        <a href="${pageContext.request.contextPath}/routes/list"
           style="color:#64748b;text-decoration:none;font-size:.82rem">
            <i class="bi bi-arrow-left me-1"></i>Back to Route Network
        </a>
    </div>
    <h5 class="fw-bold mb-4">
        <i class="bi bi-map-fill me-2" style="color:#3b82f6"></i>
        ${empty route ? 'Define New Route' : 'Edit Route'}
    </h5>

    <div class="card p-4">
        <form method="post" action="${pageContext.request.contextPath}/routes/save" novalidate id="routeForm">
            <input type="hidden" name="routeId" value="${route.routeId}">

            <div class="mb-3">
                <label class="form-label fw-semibold">Route Name</label>
                <input type="text" name="routeName" id="routeName" class="form-control"
                       value="${route.routeName}" placeholder="e.g. Route 1 – Soshanguve North → Pretoria" required>
            </div>

            <!-- ── Origin ─────────────────────────────────────────────── -->
            <div class="mb-1">
                <label class="form-label fw-semibold">
                    <i class="bi bi-geo-alt" style="color:#22c55e"></i> Origin Campus / Terminal
                </label>
                <div class="d-flex gap-2 mb-2">
                    <select id="originPreset" class="form-select form-select-sm" style="max-width:260px"
                            onchange="applyPreset('origin', this.value)">
                        <option value="">— pick a campus preset —</option>
                        <option value="-25.5275,28.0952">Soshanguve North Campus</option>
                        <option value="-25.5358,28.1065">Soshanguve South Campus</option>
                        <option value="-25.7313,28.1648">Pretoria Campus</option>
                        <option value="-25.7469,28.1961">Arcadia Campus</option>
                        <option value="-25.6169,27.9964">Ga-Rankuwa Campus</option>
                    </select>
                    <span class="campus-badge align-self-center">TUT Campuses</span>
                </div>
                <input type="text" name="startLocation" id="startLocation" class="form-control mb-2"
                       value="${route.startLocation}" placeholder="e.g. Soshanguve North Campus" required>
                <div class="coord-row">
                    <input type="number" step="any" name="startLat" id="startLat" class="form-control"
                           value="${route.startLat}" placeholder="Latitude e.g. -25.5275">
                    <input type="number" step="any" name="startLng" id="startLng" class="form-control"
                           value="${route.startLng}" placeholder="Longitude e.g. 28.0952">
                </div>
            </div>

            <div class="text-center my-2" style="color:#94a3b8;font-size:1.3rem">
                <i class="bi bi-arrow-down"></i>
            </div>

            <!-- ── Destination ─────────────────────────────────────────── -->
            <div class="mb-3">
                <label class="form-label fw-semibold">
                    <i class="bi bi-geo-alt-fill" style="color:#ef4444"></i> Destination Campus / Terminal
                </label>
                <div class="d-flex gap-2 mb-2">
                    <select id="destPreset" class="form-select form-select-sm" style="max-width:260px"
                            onchange="applyPreset('dest', this.value)">
                        <option value="">— pick a campus preset —</option>
                        <option value="-25.5275,28.0952">Soshanguve North Campus</option>
                        <option value="-25.5358,28.1065">Soshanguve South Campus</option>
                        <option value="-25.7313,28.1648">Pretoria Campus</option>
                        <option value="-25.7469,28.1961">Arcadia Campus</option>
                        <option value="-25.6169,27.9964">Ga-Rankuwa Campus</option>
                    </select>
                </div>
                <input type="text" name="endLocation" id="endLocation" class="form-control mb-2"
                       value="${route.endLocation}" placeholder="e.g. Pretoria Campus" required>
                <div class="coord-row">
                    <input type="number" step="any" name="endLat" id="endLat" class="form-control"
                           value="${route.endLat}" placeholder="Latitude e.g. -25.7313">
                    <input type="number" step="any" name="endLng" id="endLng" class="form-control"
                           value="${route.endLng}" placeholder="Longitude e.g. 28.1648">
                </div>
            </div>

            <!-- ── Live Preview Map ───────────────────────────────────── -->
            <div id="preview-map"></div>

            <hr>
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary px-4">
                    <i class="bi bi-check-lg me-1"></i>${empty route ? 'Create Route' : 'Save Changes'}
                </button>
                <a href="${pageContext.request.contextPath}/routes/list"
                   class="btn btn-outline-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
const CAMPUSES = {
    'Soshanguve North Campus':  [-25.5275, 28.0952],
    'Soshanguve South Campus':  [-25.5358, 28.1065],
    'Pretoria Campus':          [-25.7313, 28.1648],
    'Arcadia Campus':           [-25.7469, 28.1961],
    'Ga-Rankuwa Campus':        [-25.6169, 27.9964]
};

const NAMES = {
    '-25.5275,28.0952': 'Soshanguve North Campus',
    '-25.5358,28.1065': 'Soshanguve South Campus',
    '-25.7313,28.1648': 'Pretoria Campus',
    '-25.7469,28.1961': 'Arcadia Campus',
    '-25.6169,27.9964': 'Ga-Rankuwa Campus'
};

// Initialise map
const map = L.map('preview-map', { zoomControl:true, attributionControl:false })
    .setView([-25.65, 28.09], 11);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom:18 }).addTo(map);

let originMarker = null, destMarker = null, routeLine = null;

function markerIcon(color) {
    return L.divIcon({
        className:'',
        html:'<div style="width:14px;height:14px;border-radius:50%;background:'+color+';border:2px solid #fff;box-shadow:0 0 4px rgba(0,0,0,.4)"></div>',
        iconSize:[14,14], iconAnchor:[7,7]
    });
}

function updateMap() {
    const sLat = parseFloat(document.getElementById('startLat').value);
    const sLng = parseFloat(document.getElementById('startLng').value);
    const eLat = parseFloat(document.getElementById('endLat').value);
    const eLng = parseFloat(document.getElementById('endLng').value);

    if (originMarker) { map.removeLayer(originMarker); originMarker = null; }
    if (destMarker)   { map.removeLayer(destMarker);   destMarker   = null; }
    if (routeLine)    { map.removeLayer(routeLine);    routeLine    = null; }

    const pts = [];
    if (!isNaN(sLat) && !isNaN(sLng)) {
        originMarker = L.marker([sLat, sLng], { icon: markerIcon('#22c55e') }).addTo(map)
            .bindPopup(document.getElementById('startLocation').value || 'Origin');
        pts.push([sLat, sLng]);
    }
    if (!isNaN(eLat) && !isNaN(eLng)) {
        destMarker = L.marker([eLat, eLng], { icon: markerIcon('#ef4444') }).addTo(map)
            .bindPopup(document.getElementById('endLocation').value || 'Destination');
        pts.push([eLat, eLng]);
    }
    if (pts.length === 2) {
        routeLine = L.polyline(pts, { color:'#3b82f6', weight:3, dashArray:'6 4' }).addTo(map);
        map.fitBounds(routeLine.getBounds(), { padding:[30,30] });
    } else if (pts.length === 1) {
        map.setView(pts[0], 13);
    }
}

function applyPreset(side, value) {
    if (!value) return;
    const [lat, lng] = value.split(',');
    const name = NAMES[value] || '';
    if (side === 'origin') {
        document.getElementById('startLat').value = lat;
        document.getElementById('startLng').value = lng;
        if (!document.getElementById('startLocation').value) {
            document.getElementById('startLocation').value = name;
        }
    } else {
        document.getElementById('endLat').value = lat;
        document.getElementById('endLng').value = lng;
        if (!document.getElementById('endLocation').value) {
            document.getElementById('endLocation').value = name;
        }
    }
    updateMap();
}

// Re-draw map whenever coordinates are edited manually
['startLat','startLng','endLat','endLng'].forEach(id => {
    document.getElementById(id).addEventListener('input', updateMap);
});

// Initial draw (edit mode — values already in fields)
updateMap();
</script>
</body>
</html>
