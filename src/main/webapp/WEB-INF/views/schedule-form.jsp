<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${empty schedule ? 'Add Schedule' : 'Edit Schedule'} – SmartBus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container sb-main" style="max-width:480px">
    <div class="mb-3">
        <a href="${pageContext.request.contextPath}/schedules/list"
           style="color:#64748b;text-decoration:none;font-size:.82rem">
            <i class="bi bi-arrow-left me-1"></i>Back to Service Schedules
        </a>
    </div>
    <h5 class="fw-bold mb-4">
        <i class="bi bi-calendar3 me-2" style="color:#3b82f6"></i>
        ${empty schedule ? 'Define New Schedule' : 'Edit Schedule'}
    </h5>
    <div class="card p-4">
        <form method="post" action="${pageContext.request.contextPath}/schedules/save" novalidate>
            <input type="hidden" name="scheduleId" value="${schedule.scheduleId}">
            <div class="mb-3">
                <label class="form-label">Service Route</label>
                <select name="routeId" class="form-select" required>
                    <option value="">-- Select Route --</option>
                    <c:forEach var="r" items="${routes}">
                        <option value="${r.routeId}" ${schedule.route.routeId == r.routeId ? 'selected' : ''}>
                            ${r.routeName}
                        </option>
                    </c:forEach>
                </select>
            </div>
            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label">Scheduled Departure</label>
                    <input type="time" name="departureTime" class="form-control"
                           value="${schedule.departureTime}" required>
                </div>
                <div class="col-md-6 mb-3">
                    <label class="form-label">Scheduled Arrival</label>
                    <input type="time" name="arrivalTime" class="form-control"
                           value="${schedule.arrivalTime}" required>
                </div>
            </div>
            <hr>
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary px-4">
                    <i class="bi bi-check-lg me-1"></i>${empty schedule ? 'Create Schedule' : 'Save Changes'}
                </button>
                <a href="${pageContext.request.contextPath}/schedules/list"
                   class="btn btn-outline-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
