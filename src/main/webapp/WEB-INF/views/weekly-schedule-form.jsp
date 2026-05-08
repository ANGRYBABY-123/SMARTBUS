<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${empty ds ? 'Add Schedule Entry' : 'Edit Schedule Entry'} – SmartBus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container sb-main" style="max-width:580px">
    <div class="mb-3">
        <a href="${pageContext.request.contextPath}/weekly-schedule/list"
           style="color:#64748b;text-decoration:none;font-size:.82rem">
            <i class="bi bi-arrow-left me-1"></i>Back to Weekly Schedule
        </a>
    </div>
    <h5 class="fw-bold mb-4">
        <i class="bi bi-calendar-week me-2" style="color:#3b82f6"></i>
        ${empty ds ? 'Add Schedule Entry' : 'Edit Schedule Entry'}
    </h5>

    <div class="card p-4">
        <form method="post"
              action="${pageContext.request.contextPath}/weekly-schedule/save"
              novalidate>
            <input type="hidden" name="dsId" value="${ds.id}">

            <%-- Week start date --%>
            <div class="mb-3">
                <label class="form-label">Week Starting</label>
                <input type="date" name="weekStartDate" class="form-control" required
                       value="${empty ds ? '' : ds.weekStartDate}">
                <div style="color:#60a5fa;font-size:.72rem;margin-top:.3rem">
                    <i class="bi bi-info-circle me-1"></i>
                    Dates are automatically snapped to the Monday of that week.
                </div>
            </div>

            <%-- Driver --%>
            <div class="mb-3">
                <label class="form-label">Driver</label>
                <select name="driverId" class="form-select" required>
                    <option value="">-- Select Driver --</option>
                    <c:forEach var="d" items="${drivers}">
                        <option value="${d.userId}"
                            ${ds.driver.userId == d.userId ? 'selected' : ''}>
                            ${d.name}
                        </option>
                    </c:forEach>
                </select>
                <c:if test="${empty drivers}">
                    <div style="color:#f87171;font-size:.76rem;margin-top:.3rem">
                        <i class="bi bi-exclamation-triangle me-1"></i>
                        No drivers found. Register users with the "Driver" role first.
                    </div>
                </c:if>
            </div>

            <%-- Bus --%>
            <div class="mb-3">
                <label class="form-label">Vehicle</label>
                <select name="busId" class="form-select" required>
                    <option value="">-- Select Bus --</option>
                    <c:forEach var="b" items="${buses}">
                        <option value="${b.busId}"
                            ${ds.bus.busId == b.busId ? 'selected' : ''}>
                            ${b.registrationNumber} &nbsp;(${b.capacity} seats)
                        </option>
                    </c:forEach>
                </select>
            </div>

            <%-- Route --%>
            <div class="mb-3">
                <label class="form-label">Route</label>
                <select name="routeId" class="form-select" required>
                    <option value="">-- Select Route --</option>
                    <c:forEach var="r" items="${routes}">
                        <option value="${r.routeId}"
                            ${ds.route.routeId == r.routeId ? 'selected' : ''}>
                            ${r.routeName} &nbsp;(${r.startLocation} &rarr; ${r.endLocation})
                        </option>
                    </c:forEach>
                </select>
            </div>

            <%-- Shift type --%>
            <div class="mb-3">
                <label class="form-label">Schedule Type</label>
                <select name="shiftType" class="form-select" required>
                    <option value="">-- Select Shift --</option>
                    <option value="Morning"   ${ds.shiftType == 'Morning'   ? 'selected' : ''}>Morning</option>
                    <option value="Afternoon" ${ds.shiftType == 'Afternoon' ? 'selected' : ''}>Afternoon</option>
                    <option value="Shuttle"   ${ds.shiftType == 'Shuttle'   ? 'selected' : ''}>Shuttle</option>
                </select>
            </div>

            <%-- Shift hours --%>
            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label">Start Time</label>
                    <input type="time" name="shiftStart" class="form-control" required
                           value="${ds.shiftStart}">
                </div>
                <div class="col-md-6 mb-3">
                    <label class="form-label">End Time</label>
                    <input type="time" name="shiftEnd" class="form-control" required
                           value="${ds.shiftEnd}">
                </div>
            </div>

            <hr>
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary px-4">
                    <i class="bi bi-check-lg me-1"></i>
                    ${empty ds ? 'Add Entry' : 'Save Changes'}
                </button>
                <a href="${pageContext.request.contextPath}/weekly-schedule/list"
                   class="btn btn-outline-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
