<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><title>Fleet Registry – SmartBus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container-fluid sb-main">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 class="fw-bold mb-0">
            <i class="bi bi-bus-front me-2" style="color:#3b82f6"></i>Fleet Registry
        </h5>
        <a href="${pageContext.request.contextPath}/buses/new" class="btn btn-primary btn-sm">
            <i class="bi bi-plus-lg me-1"></i>Register Vehicle
        </a>
    </div>
    <div class="card">
        <table class="table table-hover mb-0">
            <thead>
                <tr><th>#</th><th>Vehicle Registration</th><th>Passenger Capacity</th><th>Actions</th></tr>
            </thead>
            <tbody>
            <c:forEach var="b" items="${buses}">
                <tr>
                    <td style="color:#64748b;font-size:.8rem">${b.busId}</td>
                    <td><span style="font-weight:600;font-family:monospace;color:#93c5fd">${b.registrationNumber}</span></td>
                    <td>${b.capacity}&nbsp;<span style="color:#64748b;font-size:.82rem">seats</span></td>
                    <td>
                        <a href="${pageContext.request.contextPath}/buses/edit?id=${b.busId}"
                           class="btn btn-sm btn-outline-primary" title="Edit"><i class="bi bi-pencil"></i></a>
                        <a href="${pageContext.request.contextPath}/buses/delete?id=${b.busId}"
                           class="btn btn-sm btn-outline-danger" title="Remove from fleet"
                           onclick="return confirm('Remove vehicle ${b.registrationNumber} from the fleet?')"><i class="bi bi-trash"></i></a>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty buses}">
                <tr><td colspan="4" class="text-center py-4" style="color:#64748b">No vehicles registered in the fleet.</td></tr>
            </c:if>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
