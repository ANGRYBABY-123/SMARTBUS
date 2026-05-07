<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><title>Route Network – SmartBus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container-fluid sb-main">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 class="fw-bold mb-0">
            <i class="bi bi-map-fill me-2" style="color:#3b82f6"></i>Route Network
        </h5>
        <a href="${pageContext.request.contextPath}/routes/new" class="btn btn-primary btn-sm">
            <i class="bi bi-plus-lg me-1"></i>Add Route
        </a>
    </div>
    <div class="card">
        <table class="table table-hover mb-0">
            <thead>
                <tr><th>#</th><th>Route Name</th><th>Origin Terminal</th><th>Destination Terminal</th><th>Actions</th></tr>
            </thead>
            <tbody>
            <c:forEach var="r" items="${routes}">
                <tr>
                    <td style="color:#64748b;font-size:.8rem">${r.routeId}</td>
                    <td style="font-weight:600">${r.routeName}</td>
                    <td><i class="bi bi-geo-alt" style="color:#22c55e;font-size:.8rem"></i> ${r.startLocation}</td>
                    <td><i class="bi bi-geo-alt-fill" style="color:#ef4444;font-size:.8rem"></i> ${r.endLocation}</td>
                    <td>
                        <a href="${pageContext.request.contextPath}/routes/edit?id=${r.routeId}"
                           class="btn btn-sm btn-outline-primary" title="Edit"><i class="bi bi-pencil"></i></a>
                        <a href="${pageContext.request.contextPath}/routes/delete?id=${r.routeId}"
                           class="btn btn-sm btn-outline-danger" title="Delete"
                           onclick="return confirm('Delete route ${r.routeName}?')"><i class="bi bi-trash"></i></a>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty routes}">
                <tr><td colspan="5" class="text-center py-4" style="color:#64748b">No routes defined.</td></tr>
            </c:if>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
