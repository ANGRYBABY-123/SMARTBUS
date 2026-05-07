<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${empty trip ? 'Dispatch Trip' : 'Edit Trip'} – SmartBus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container sb-main" style="max-width:580px">
    <div class="mb-3">
        <a href="${pageContext.request.contextPath}/trips/list"
           style="color:#64748b;text-decoration:none;font-size:.82rem">
            <i class="bi bi-arrow-left me-1"></i>Back to Trip Dispatch
        </a>
    </div>
    <h5 class="fw-bold mb-4">
        <i class="bi bi-signpost-split-fill me-2" style="color:#3b82f6"></i>
        ${empty trip ? 'Dispatch New Trip' : 'Edit Trip Record'}
    </h5>
    <div class="card p-4">
        <form method="post" action="${pageContext.request.contextPath}/trips/save" novalidate>
            <input type="hidden" name="tripId" value="${trip.tripId}">

            <div class="mb-3">
                <label class="form-label">Assigned Driver</label>
                <select name="driverId" class="form-select" required>
                    <option value="">-- Select Driver --</option>
                    <c:forEach var="d" items="${drivers}">
                        <option value="${d.userId}" ${trip.driver.userId == d.userId ? 'selected' : ''}>
                            ${d.name}
                        </option>
                    </c:forEach>
                </select>
                <c:if test="${empty drivers}">
                    <div style="color:#f87171;font-size:.76rem;margin-top:.3rem">
                        <i class="bi bi-exclamation-triangle me-1"></i>
                        No drivers available. Register users with the "Driver" role first.
                    </div>
                </c:if>
            </div>

            <div class="mb-3">
                <label class="form-label">Assigned Vehicle</label>
                <select name="busId" class="form-select" required>
                    <option value="">-- Select Vehicle --</option>
                    <c:forEach var="b" items="${buses}">
                        <option value="${b.busId}" ${trip.bus.busId == b.busId ? 'selected' : ''}>
                            ${b.registrationNumber} &nbsp;(${b.capacity} seats)
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="mb-3">
                <label class="form-label">Service Route</label>
                <select name="routeId" class="form-select" required>
                    <option value="">-- Select Route --</option>
                    <c:forEach var="r" items="${routes}">
                        <option value="${r.routeId}" ${trip.route.routeId == r.routeId ? 'selected' : ''}>
                            ${r.routeName} &nbsp;(${r.startLocation} &rarr; ${r.endLocation})
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label">Scheduled Departure</label>
                    <input type="datetime-local" name="startTime" class="form-control"
                           value="${trip.startTime}">
                </div>
                <div class="col-md-6 mb-3">
                    <label class="form-label">Actual / Expected Arrival</label>
                    <input type="datetime-local" name="endTime" class="form-control"
                           value="${trip.endTime}">
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label">Trip Status</label>
                <select name="status" class="form-select" required>
                    <option value="SCHEDULED"   ${trip.status=='SCHEDULED'  ?'selected':''}>Scheduled</option>
                    <option value="IN_PROGRESS" ${trip.status=='IN_PROGRESS'?'selected':''}>In Progress</option>
                    <option value="COMPLETED"   ${trip.status=='COMPLETED'  ?'selected':''}>Completed</option>
                    <option value="CANCELLED"   ${trip.status=='CANCELLED'  ?'selected':''}>Cancelled</option>
                </select>
            </div>

            <hr>
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary px-4">
                    <i class="bi bi-check-lg me-1"></i>${empty trip ? 'Dispatch Trip' : 'Save Changes'}
                </button>
                <a href="${pageContext.request.contextPath}/trips/list"
                   class="btn btn-outline-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
