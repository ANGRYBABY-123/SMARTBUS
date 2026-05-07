<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SmartBus – Fleet Command</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background: #0f172a; color: #e2e8f0; font-family: 'Segoe UI', sans-serif; margin: 0; }

        /* Sidebar */
        .sidebar {
            width: 240px; min-width: 240px; min-height: 100vh;
            background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%);
            border-right: 1px solid #1e293b;
            padding: 24px 16px;
            display: flex; flex-direction: column;
        }
        .brand { font-size: 1.25rem; font-weight: 800; color: #fff; letter-spacing: -0.5px; margin-bottom: 32px; }
        .brand .dot { color: #6366f1; }
        .nav-section { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 1.5px; color: #475569; margin: 16px 0 8px 8px; }
        .sidebar a {
            display: flex; align-items: center; gap: 10px;
            color: #94a3b8; text-decoration: none;
            padding: 9px 12px; border-radius: 8px;
            font-size: 0.88rem; font-weight: 500;
            transition: all 0.15s;
        }
        .sidebar a:hover, .sidebar a.active { background: #1e293b; color: #fff; }
        .sidebar a i { font-size: 1rem; width: 18px; text-align: center; }
        .sidebar a.danger { color: #f87171; }
        .sidebar a.danger:hover { background: rgba(248,113,113,0.1); color: #f87171; }
        .sidebar-footer { margin-top: auto; }

        /* Main content */
        .main { flex: 1; padding: 32px; overflow-y: auto; min-height: 100vh; }

        /* Header bar */
        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 32px; }
        .page-title { font-size: 1.6rem; font-weight: 800; color: #fff; }
        .page-subtitle { font-size: 0.85rem; color: #64748b; margin-top: 2px; }
        .admin-chip {
            background: #6366f1; color: #fff;
            padding: 4px 12px; border-radius: 20px;
            font-size: 0.8rem; font-weight: 600;
            display: flex; align-items: center; gap: 6px;
        }

        /* Stat cards */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; margin-bottom: 28px; }
        .stat-card {
            background: #1e293b; border-radius: 16px; padding: 20px;
            border: 1px solid #334155; position: relative; overflow: hidden;
        }
        .stat-card::before {
            content: ''; position: absolute; top: 0; left: 0;
            width: 4px; height: 100%; border-radius: 16px 0 0 16px;
        }
        .stat-card.blue::before { background: #6366f1; }
        .stat-card.green::before { background: #22c55e; }
        .stat-card.amber::before { background: #f59e0b; }
        .stat-card.red::before { background: #ef4444; }
        .stat-card.purple::before { background: #a855f7; }
        .stat-icon { font-size: 1.4rem; margin-bottom: 10px; }
        .stat-label { font-size: 0.75rem; text-transform: uppercase; letter-spacing: 1px; color: #64748b; margin-bottom: 4px; }
        .stat-value { font-size: 2rem; font-weight: 800; color: #fff; }

        /* Panels */
        .panel { background: #1e293b; border-radius: 16px; border: 1px solid #334155; overflow: hidden; }
        .panel-header { padding: 16px 20px; border-bottom: 1px solid #334155; font-weight: 700; font-size: 0.9rem; display: flex; align-items: center; gap: 8px; }
        .panel-body { padding: 16px 20px; }

        /* Quick action buttons */
        .action-btn {
            display: flex; flex-direction: column; align-items: center; gap: 6px;
            background: #0f172a; border: 1px solid #334155;
            color: #94a3b8; text-decoration: none;
            padding: 16px 12px; border-radius: 12px; font-size: 0.78rem;
            font-weight: 600; text-align: center; transition: all 0.15s;
            min-width: 90px;
        }
        .action-btn i { font-size: 1.4rem; }
        .action-btn:hover { background: #6366f1; border-color: #6366f1; color: #fff; transform: translateY(-2px); }

        /* Active trips table */
        .live-table { width: 100%; border-collapse: collapse; }
        .live-table th { font-size: 0.72rem; text-transform: uppercase; letter-spacing: 1px; color: #475569; padding: 8px 12px; border-bottom: 1px solid #334155; }
        .live-table td { padding: 12px 12px; border-bottom: 1px solid #1e293b; font-size: 0.88rem; color: #cbd5e1; }
        .live-table tr:last-child td { border-bottom: none; }
        .badge-live { background: rgba(34,197,94,0.15); color: #22c55e; padding: 3px 10px; border-radius: 20px; font-size: 0.72rem; font-weight: 700; }
        .btn-track { background: #6366f1; color: #fff; border: none; padding: 5px 14px; border-radius: 8px; font-size: 0.78rem; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; gap: 4px; }
        .btn-track:hover { background: #4f46e5; color: #fff; }
        .empty-row td { text-align: center; color: #475569; padding: 32px; }
    </style>
</head>
<body>
<div class="d-flex">
    <!-- Sidebar -->
    <div class="sidebar">
        <div class="brand">Smart<span class="dot">Bus</span></div>
        <div class="nav-section">Main</div>
        <a href="${pageContext.request.contextPath}/dashboard"><i class="bi bi-speedometer2"></i> Overview</a>
        <a href="${pageContext.request.contextPath}/trips/list"><i class="bi bi-arrow-left-right"></i> Trips</a>
        <a href="${pageContext.request.contextPath}/buses/list"><i class="bi bi-bus-front"></i> Fleet</a>
        <a href="${pageContext.request.contextPath}/routes/list"><i class="bi bi-map"></i> Routes</a>
        <a href="${pageContext.request.contextPath}/schedules/list"><i class="bi bi-calendar3"></i> Schedules</a>
        <div class="nav-section">Users</div>
        <a href="${pageContext.request.contextPath}/users/list"><i class="bi bi-people"></i> All Users</a>
        <div class="sidebar-footer">
            <hr style="border-color:#334155">
            <a href="${pageContext.request.contextPath}/users/logout" class="danger"><i class="bi bi-box-arrow-right"></i> Logout</a>
        </div>
    </div>

    <!-- Main -->
    <div class="main">
        <!-- Header -->
        <div class="page-header">
            <div>
                <div class="page-title">Fleet Command Center</div>
                <div class="page-subtitle">Real-time overview of your SmartBus operations</div>
            </div>
            <div class="admin-chip"><i class="bi bi-shield-fill-check"></i> Admin</div>
        </div>

        <!-- Stats -->
        <div class="stats-grid">
            <div class="stat-card blue">
                <div class="stat-icon">🚌</div>
                <div class="stat-label">Total Buses</div>
                <div class="stat-value">${totalBuses}</div>
            </div>
            <div class="stat-card green">
                <div class="stat-icon">⚡</div>
                <div class="stat-label">Active Trips</div>
                <div class="stat-value">${activeTripsCount}</div>
            </div>
            <div class="stat-card amber">
                <div class="stat-icon">🗺</div>
                <div class="stat-label">Total Routes</div>
                <div class="stat-value">${totalRoutes}</div>
            </div>
            <div class="stat-card red">
                <div class="stat-icon">👥</div>
                <div class="stat-label">Total Users</div>
                <div class="stat-value">${totalUsers}</div>
            </div>
        </div>

        <div class="row g-3">
            <!-- Quick Actions -->
            <div class="col-12 col-xl-4">
                <div class="panel">
                    <div class="panel-header"><i class="bi bi-lightning-fill" style="color:#f59e0b"></i> Quick Actions</div>
                    <div class="panel-body">
                        <div class="d-flex flex-wrap gap-2">
                            <a href="${pageContext.request.contextPath}/trips/new" class="action-btn"><i class="bi bi-plus-circle-fill"></i>New Trip</a>
                            <a href="${pageContext.request.contextPath}/buses/new" class="action-btn"><i class="bi bi-bus-front-fill"></i>Add Bus</a>
                            <a href="${pageContext.request.contextPath}/routes/new" class="action-btn"><i class="bi bi-signpost-split-fill"></i>Add Route</a>
                            <a href="${pageContext.request.contextPath}/users/new" class="action-btn"><i class="bi bi-person-plus-fill"></i>Add User</a>
                            <a href="${pageContext.request.contextPath}/schedules/new" class="action-btn"><i class="bi bi-calendar-plus-fill"></i>Add Schedule</a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Live Trips -->
            <div class="col-12 col-xl-8">
                <div class="panel">
                    <div class="panel-header">
                        <span style="width:8px;height:8px;border-radius:50%;background:#22c55e;display:inline-block;animation:pulse2 1.4s infinite"></span>
                        Live Trips
                    </div>
                    <table class="live-table">
                        <thead>
                            <tr>
                                <th>Route</th>
                                <th>Driver</th>
                                <th>Bus</th>
                                <th>Status</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty activeTripsList}">
                                <c:forEach var="t" items="${activeTripsList}">
                                <tr>
                                    <td>${t.route.routeName}</td>
                                    <td>${t.driver.name}</td>
                                    <td>${t.bus.registrationNumber}</td>
                                    <td><span class="badge-live">● Live</span></td>
                                    <td><a href="${pageContext.request.contextPath}/tracking/view?tripId=${t.tripId}" class="btn-track" target="_blank"><i class="bi bi-geo-alt-fill"></i> Track</a></td>
                                </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr class="empty-row"><td colspan="5">No active trips right now</td></tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<style>
@keyframes pulse2 {
    0%,100%{box-shadow:0 0 0 0 rgba(34,197,94,.5)}
    50%{box-shadow:0 0 0 5px rgba(34,197,94,0)}
}
</style>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
