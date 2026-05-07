<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${empty route ? 'Add Route' : 'Edit Route'} – SmartBus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container sb-main" style="max-width:480px">
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
        <form method="post" action="${pageContext.request.contextPath}/routes/save" novalidate>
            <input type="hidden" name="routeId" value="${route.routeId}">
            <div class="mb-3">
                <label class="form-label">Route Name</label>
                <input type="text" name="routeName" class="form-control"
                       value="${route.routeName}" placeholder="e.g. Route A – City Express" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Origin Terminal</label>
                <input type="text" name="startLocation" class="form-control"
                       value="${route.startLocation}" placeholder="e.g. Central Station" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Destination Terminal</label>
                <input type="text" name="endLocation" class="form-control"
                       value="${route.endLocation}" placeholder="e.g. Airport Terminal 2" required>
            </div>
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
</body>
</html>
