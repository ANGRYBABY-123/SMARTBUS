<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><title>Bus Stops – CommuteSafe</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container-fluid sb-main">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h5 class="fw-bold mb-0">
                <i class="bi bi-pin-map-fill me-2" style="color:#3b82f6"></i>Bus Stops
            </h5>
            <small style="color:#64748b">GPS terminals used to recommend nearest stop to passengers.</small>
        </div>
        <a href="${pageContext.request.contextPath}/stops/new" class="btn btn-primary btn-sm">
            <i class="bi bi-plus-lg me-1"></i>Add Stop
        </a>
    </div>
    <div class="card">
        <table class="table table-hover mb-0">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Stop Name</th>
                    <th>GPS Coordinates</th>
                    <th>Routes Served</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <c:forEach var="s" items="${stops}">
                <tr>
                    <td style="color:#64748b;font-size:.8rem">${s.stopId}</td>
                    <td style="font-weight:600">
                        <i class="bi bi-geo-alt-fill me-1" style="color:#22c55e"></i>${s.name}
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${s.latitude != null and s.longitude != null}">
                                <span style="font-family:monospace;font-size:.82rem;color:#93c5fd">
                                    ${s.latitude}, ${s.longitude}
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span style="color:#64748b;font-size:.82rem">Not set</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${not empty s.routes}">
                                <c:forEach var="r" items="${s.routes}">
                                    <span class="badge" style="background:#1e3a5f;color:#93c5fd;margin-right:2px">
                                        ${r.routeName}
                                    </span>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <span style="color:#64748b;font-size:.82rem">No routes assigned</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <a href="${pageContext.request.contextPath}/stops/edit?id=${s.stopId}"
                           class="btn btn-sm btn-outline-primary" title="Edit">
                            <i class="bi bi-pencil"></i>
                        </a>
                        <a href="${pageContext.request.contextPath}/stops/delete?id=${s.stopId}"
                           class="btn btn-sm btn-outline-danger" title="Delete"
                           onclick="return confirm('Delete stop ${s.name}?')">
                            <i class="bi bi-trash"></i>
                        </a>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty stops}">
                <tr>
                    <td colspan="5" class="text-center py-5" style="color:#64748b">
                        <i class="bi bi-pin-map" style="font-size:2rem;display:block;margin-bottom:8px;opacity:.4"></i>
                        No bus stops added yet.<br>
                        <a href="${pageContext.request.contextPath}/stops/new" style="color:#3b82f6">Add your first stop</a>
                        to enable GPS-based stop recommendations for passengers.
                    </td>
                </tr>
            </c:if>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
