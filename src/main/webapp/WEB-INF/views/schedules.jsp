<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><title>Service Schedules – SmartBus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container-fluid sb-main">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 class="fw-bold mb-0">
            <i class="bi bi-calendar3 me-2" style="color:#3b82f6"></i>Service Schedules
        </h5>
        <a href="${pageContext.request.contextPath}/schedules/new" class="btn btn-primary btn-sm">
            <i class="bi bi-plus-lg me-1"></i>Add Schedule
        </a>
    </div>
    <div class="card">
        <table class="table table-hover mb-0">
            <thead>
                <tr><th>#</th><th>Service Route</th><th>Scheduled Departure</th><th>Scheduled Arrival</th><th>Actions</th></tr>
            </thead>
            <tbody>
            <c:forEach var="s" items="${schedules}">
                <tr>
                    <td style="color:#64748b;font-size:.8rem">${s.scheduleId}</td>
                    <td style="font-weight:500">${s.route.routeName}</td>
                    <td style="color:#34d399">${s.departureTime}</td>
                    <td style="color:#f87171">${s.arrivalTime}</td>
                    <td>
                        <a href="${pageContext.request.contextPath}/schedules/edit?id=${s.scheduleId}"
                           class="btn btn-sm btn-outline-primary" title="Edit"><i class="bi bi-pencil"></i></a>
                        <a href="${pageContext.request.contextPath}/schedules/delete?id=${s.scheduleId}"
                           class="btn btn-sm btn-outline-danger" title="Delete"
                           onclick="return confirm('Delete this schedule?')"><i class="bi bi-trash"></i></a>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty schedules}">
                <tr><td colspan="5" class="text-center py-4" style="color:#64748b">No schedules defined.</td></tr>
            </c:if>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
