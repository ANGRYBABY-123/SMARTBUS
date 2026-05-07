<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><title>Trip Dispatch – SmartBus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container-fluid sb-main">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 class="fw-bold mb-0">
            <i class="bi bi-signpost-split-fill me-2" style="color:#3b82f6"></i>Trip Dispatch
        </h5>
        <a href="${pageContext.request.contextPath}/trips/new" class="btn btn-primary btn-sm">
            <i class="bi bi-plus-lg me-1"></i>Dispatch Trip
        </a>
    </div>
    <form class="d-flex gap-2 mb-3" method="get" action="${pageContext.request.contextPath}/trips/list">
        <select name="status" class="form-select form-select-sm" style="max-width:210px">
            <option value="">All Statuses</option>
            <option value="SCHEDULED"   ${param.status=='SCHEDULED'  ?'selected':''}>Scheduled</option>
            <option value="IN_PROGRESS" ${param.status=='IN_PROGRESS'?'selected':''}>In Progress</option>
            <option value="COMPLETED"   ${param.status=='COMPLETED'  ?'selected':''}>Completed</option>
            <option value="CANCELLED"   ${param.status=='CANCELLED'  ?'selected':''}>Cancelled</option>
        </select>
        <button class="btn btn-sm btn-outline-secondary"><i class="bi bi-funnel me-1"></i>Filter</button>
    </form>
    <div class="card">
        <table class="table table-hover mb-0">
            <thead>
                <tr>
                    <th>#</th><th>Assigned Driver</th><th>Assigned Vehicle</th>
                    <th>Service Route</th><th>Scheduled Departure</th><th>Trip Status</th><th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <c:forEach var="t" items="${trips}">
                <tr>
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
                        <a href="${pageContext.request.contextPath}/trips/edit?id=${t.tripId}"
                           class="btn btn-sm btn-outline-primary" title="Edit"><i class="bi bi-pencil"></i></a>
                        <a href="${pageContext.request.contextPath}/trips/delete?id=${t.tripId}"
                           class="btn btn-sm btn-outline-danger" title="Delete"
                           onclick="return confirm('Delete trip #${t.tripId}?')"><i class="bi bi-trash"></i></a>
                        <c:if test="${t.status=='IN_PROGRESS'}">
                            <a href="${pageContext.request.contextPath}/tracking/view?tripId=${t.tripId}"
                               class="btn btn-sm btn-success" target="_blank" title="Live GPS Tracking">
                                <i class="bi bi-geo-alt-fill"></i>&nbsp;Track
                            </a>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty trips}">
                <tr><td colspan="7" class="text-center py-4" style="color:#64748b">No trips found.</td></tr>
            </c:if>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
<div class="container-fluid p-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4 class="fw-bold">Trips</h4>
        <a href="${pageContext.request.contextPath}/trips/new" class="btn btn-primary btn-sm"><i class="bi bi-plus"></i> New Trip</a>
    </div>
    <form class="d-flex gap-2 mb-3" method="get" action="${pageContext.request.contextPath}/trips/list">
        <select name="status" class="form-select form-select-sm" style="max-width:180px">
            <option value="">All Statuses</option>
            <option value="SCHEDULED" ${param.status == 'SCHEDULED' ? 'selected' : ''}>Scheduled</option>
            <option value="IN_PROGRESS" ${param.status == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
            <option value="COMPLETED" ${param.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
            <option value="CANCELLED" ${param.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
        </select>
        <button class="btn btn-sm btn-outline-secondary">Filter</button>
    </form>
    <div class="card">
        <table class="table table-hover mb-0">
            <thead class="table-dark">
                <tr><th>ID</th><th>Driver</th><th>Bus</th><th>Route</th><th>Start Time</th><th>Status</th><th>Actions</th></tr>
            </thead>
            <tbody>
            <c:forEach var="t" items="${trips}">
                <tr>
                    <td>${t.tripId}</td>
                    <td>${t.driver.name}</td>
                    <td>${t.bus.registrationNumber}</td>
                    <td>${t.route.routeName}</td>
                    <td>${t.startTime}</td>
                    <td>
                        <c:choose>
                            <c:when test="${t.status == 'IN_PROGRESS'}"><span class="badge bg-success">${t.status}</span></c:when>
                            <c:when test="${t.status == 'COMPLETED'}"><span class="badge bg-secondary">${t.status}</span></c:when>
                            <c:when test="${t.status == 'CANCELLED'}"><span class="badge bg-danger">${t.status}</span></c:when>
                            <c:otherwise><span class="badge bg-primary">${t.status}</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <a href="${pageContext.request.contextPath}/trips/edit?id=${t.tripId}" class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i></a>
                        <a href="${pageContext.request.contextPath}/trips/delete?id=${t.tripId}" class="btn btn-sm btn-outline-danger"
                           onclick="return confirm('Delete this trip?')"><i class="bi bi-trash"></i></a>
                        <c:if test="${t.status == 'IN_PROGRESS'}">
                            <a href="${pageContext.request.contextPath}/tracking/view?tripId=${t.tripId}"
                               class="btn btn-sm btn-success" target="_blank" title="Track live location">
                                <i class="bi bi-geo-alt-fill"></i> Track
                            </a>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty trips}">
                <tr><td colspan="7" class="text-center text-muted">No trips found.</td></tr>
            </c:if>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
