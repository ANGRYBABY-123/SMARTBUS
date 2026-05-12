<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${empty bus ? 'Register Vehicle' : 'Edit Vehicle'} – CommuteSafe</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container sb-main" style="max-width:480px">
    <div class="mb-3">
        <a href="${pageContext.request.contextPath}/buses/list"
           style="color:#64748b;text-decoration:none;font-size:.82rem">
            <i class="bi bi-arrow-left me-1"></i>Back to Fleet Registry
        </a>
    </div>
    <h5 class="fw-bold mb-4">
        <i class="bi bi-bus-front me-2" style="color:#3b82f6"></i>
        ${empty bus ? 'Register New Vehicle' : 'Edit Vehicle Record'}
    </h5>
    <div class="card p-4">
        <form method="post" action="${pageContext.request.contextPath}/buses/save" novalidate>
            <input type="hidden" name="busId" value="${bus.busId}">
            <div class="mb-3">
                <label class="form-label">Vehicle Registration No.</label>
                <input type="text" name="registrationNumber" class="form-control"
                       value="${bus.registrationNumber}" placeholder="e.g. BUS-001"
                       style="text-transform:uppercase" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Passenger Capacity (seats)</label>
                <input type="number" name="capacity" class="form-control"
                       value="${bus.capacity}" min="1" max="200" placeholder="e.g. 50" required>
            </div>
            <hr>
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary px-4">
                    <i class="bi bi-check-lg me-1"></i>${empty bus ? 'Register Vehicle' : 'Save Changes'}
                </button>
                <a href="${pageContext.request.contextPath}/buses/list"
                   class="btn btn-outline-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
