<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><title>Dashboard – SmartBus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container-fluid sb-main">

    <h5 class="fw-bold mb-4"><i class="bi bi-speedometer2 me-2" style="color:#3b82f6"></i>Dashboard</h5>

    <!-- Stat cards -->
    <div class="row g-3 mb-4">
        <div class="col-6 col-md-3">
            <div class="card p-3 text-center">
                <div style="font-size:2rem;color:#3b82f6"><i class="bi bi-bus-front-fill"></i></div>
                <div style="font-size:1.6rem;font-weight:700">${totalBuses}</div>
                <div style="font-size:.78rem;color:#94a3b8">Total Buses</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card p-3 text-center">
                <div style="font-size:2rem;color:#22c55e"><i class="bi bi-geo-alt-fill"></i></div>
                <div style="font-size:1.6rem;font-weight:700">${activeTripsCount}</div>
                <div style="font-size:.78rem;color:#94a3b8">Active Trips</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card p-3 text-center">
                <div style="font-size:2rem;color:#f59e0b"><i class="bi bi-signpost-split-fill"></i></div>
                <div style="font-size:1.6rem;font-weight:700">${totalRoutes}</div>
                <div style="font-size:.78rem;color:#94a3b8">Routes</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card p-3 text-center">
                <div style="font-size:2rem;color:#a78bfa"><i class="bi bi-people-fill"></i></div>
                <div style="font-size:1.6rem;font-weight:700">${totalUsers}</div>
                <div style="font-size:.78rem;color:#94a3b8">Users</div>
            </div>
        </div>
    </div>

    <!-- Active trips table -->
    <div class="card">
        <div class="p-3 border-bottom" style="border-color:#334155!important">
            <span style="font-weight:600;font-size:.9rem"><i class="bi bi-activity me-2" style="color:#22c55e"></i>Active Trips</span>
        </div>
        <table class="table table-hover mb-0">
            <thead>
                <tr><th>#</th><th>Route</th><th>Driver</th><th>Bus</th><th>Status</th><th>Track</th></tr>
            </thead>
            <tbody>
            <c:forEach var="t" items="${activeTripsList}">
                <tr>
                    <td style="color:#64748b;font-size:.8rem">${t.tripId}</td>
                    <td>${t.route.routeName}</td>
                    <td>${t.driver.name}</td>
                    <td style="font-family:monospace;color:#93c5fd">${t.bus.registrationNumber}</td>
                    <td><span class="badge bg-success">${t.status}</span></td>
                    <td><a href="${pageContext.request.contextPath}/tracking/view?tripId=${t.tripId}" class="btn btn-sm btn-outline-primary"><i class="bi bi-map"></i></a></td>
                </tr>
            </c:forEach>
            <c:if test="${empty activeTripsList}">
                <tr><td colspan="6" class="text-center py-4" style="color:#64748b">No active trips right now.</td></tr>
            </c:if>
            </tbody>
        </table>
    </div>

</div>
</body>
</html>
