<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html><head><title>Error</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center justify-content-center" style="min-height:100vh">
<div class="text-center">
    <c:choose>
        <c:when test="${not empty message}">
            <h1 class="display-1 text-warning">403</h1>
            <p class="lead">${message}</p>
            <a href="${pageContext.request.contextPath}/users/logout" class="btn btn-secondary">Logout</a>
        </c:when>
        <c:otherwise>
            <h1 class="display-1 text-danger">500</h1>
            <p class="lead">An internal server error occurred.</p>
            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">Back to Home</a>
        </c:otherwise>
    </c:choose>
</div>
</body></html>
