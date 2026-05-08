<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String savedDays = "";
    Object _s = request.getAttribute("schedule");
    if (_s instanceof com.smartbus.entity.Schedule) {
        String _d = ((com.smartbus.entity.Schedule) _s).getDaysOfWeek();
        if (_d != null) savedDays = _d;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${empty schedule ? 'Add Schedule' : 'Edit Schedule'} – SmartBus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .day-btn { display:none; }
        .day-label {
            display:inline-flex; align-items:center; justify-content:center;
            width:44px; height:44px; border-radius:50%; border:2px solid #e2e8f0;
            cursor:pointer; font-size:.8rem; font-weight:600; color:#64748b;
            transition:all .15s; user-select:none;
        }
        .day-btn:checked + .day-label { background:#3b82f6; border-color:#3b82f6; color:#fff; }
        .day-label:hover { border-color:#3b82f6; color:#3b82f6; }
        .day-btn:checked + .day-label:hover { color:#fff; }
    </style>
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

            <div class="mb-4">
                <label class="form-label d-block">Days of Operation</label>
                <div class="d-flex gap-2 flex-wrap">
                    <input type="checkbox" class="day-btn" name="days" id="day-MON" value="MON" <%= savedDays.contains("MON") ? "checked" : "" %>>
                    <label class="day-label" for="day-MON">Mo</label>
                    <input type="checkbox" class="day-btn" name="days" id="day-TUE" value="TUE" <%= savedDays.contains("TUE") ? "checked" : "" %>>
                    <label class="day-label" for="day-TUE">Tu</label>
                    <input type="checkbox" class="day-btn" name="days" id="day-WED" value="WED" <%= savedDays.contains("WED") ? "checked" : "" %>>
                    <label class="day-label" for="day-WED">We</label>
                    <input type="checkbox" class="day-btn" name="days" id="day-THU" value="THU" <%= savedDays.contains("THU") ? "checked" : "" %>>
                    <label class="day-label" for="day-THU">Th</label>
                    <input type="checkbox" class="day-btn" name="days" id="day-FRI" value="FRI" <%= savedDays.contains("FRI") ? "checked" : "" %>>
                    <label class="day-label" for="day-FRI">Fr</label>
                    <input type="checkbox" class="day-btn" name="days" id="day-SAT" value="SAT" <%= savedDays.contains("SAT") ? "checked" : "" %>>
                    <label class="day-label" for="day-SAT">Sa</label>
                    <input type="checkbox" class="day-btn" name="days" id="day-SUN" value="SUN" <%= savedDays.contains("SUN") ? "checked" : "" %>>
                    <label class="day-label" for="day-SUN">Su</label>
                </div>
                <div style="font-size:.75rem;color:#94a3b8;margin-top:6px">Select the days this schedule runs each week.</div>
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label">Shift Start</label>
                    <input type="time" name="departureTime" class="form-control"
                           value="${schedule.departureTime}" required>
                </div>
                <div class="col-md-6 mb-3">
                    <label class="form-label">Shift End</label>
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
