<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Weekly Driver Schedule – CommuteSafe</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .shift-morning  { background:#0d2a1f; color:#34d399; border-color:#064e3b; }
        .shift-afternoon{ background:#1e1a07; color:#fbbf24; border-color:#713f12; }
        .shift-shuttle  { background:#0d1f3c; color:#60a5fa; border-color:#1e3a5f; }
        .badge-published  { background:#064e3b; color:#34d399; }
        .badge-unpublished{ background:#3b0f0f; color:#f87171; }
        .week-pill { cursor:pointer; padding:.35rem .85rem; border-radius:20px; font-size:.75rem;
                     font-weight:700; border:1px solid var(--sb-border); color:var(--sb-muted);
                     text-decoration:none; transition:all .15s; display:inline-block; }
        .week-pill:hover,.week-pill.active { background:rgba(59,130,246,.18); color:#93c5fd;
                                             border-color:#3b82f6; }

    </style>
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container-fluid sb-main">

    <%-- Flash success message --%>
    <c:if test="${not empty flashMsg}">
        <div class="alert mb-3" style="background:#064e3b;border-color:#065f46;color:#34d399;border-radius:8px">
            <i class="bi bi-check-circle-fill me-2"></i>${flashMsg}
        </div>
    </c:if>

    <%-- Header row --%>
    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <h5 class="fw-bold mb-0">
            <i class="bi bi-calendar-week me-2" style="color:#3b82f6"></i>Weekly Driver Schedule
            <small class="ms-2" style="color:#64748b;font-size:.72rem;font-weight:400">
                Mon–Fri recurring | auto-generates trips on publish
            </small>
        </h5>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/weekly-schedule/new?week=${weekStart}"
               class="btn btn-sm" style="background:#3b82f6;color:#fff;border:none">
                <i class="bi bi-plus-lg me-1"></i>Add Entry
            </a>
            <c:if test="${unpublished > 0}">
                <form method="post" action="${pageContext.request.contextPath}/weekly-schedule/publish"
                      onsubmit="return confirm('Publish this week\'s schedule? This will create Mon–Fri trips and notify each driver.')">
                    <input type="hidden" name="weekStartDate" value="${weekStart}">
                    <button type="submit" class="btn btn-sm" style="background:#16a34a;color:#fff;border:none">
                        <i class="bi bi-send-fill me-1"></i>Publish Week
                        <span class="badge ms-1" style="background:rgba(255,255,255,.25)">${unpublished}</span>
                    </button>
                </form>
            </c:if>
        </div>
    </div>

    <%-- Week navigation pills --%>
    <div class="mb-3 d-flex flex-wrap gap-2 align-items-center">
        <span style="color:#64748b;font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em">Week of:</span>
        <%-- Current week always shown --%>
        <c:set var="currentMon" value="${weekStart}"/>
        <c:forEach var="w" items="${weeks}">
            <a href="${pageContext.request.contextPath}/weekly-schedule/list?week=${w}"
               class="week-pill ${w == weekStart ? 'active' : ''}">${w}</a>
        </c:forEach>
        <%-- Quick jump to new week --%>
        <form method="get" action="${pageContext.request.contextPath}/weekly-schedule/list"
              class="d-flex align-items-center gap-1" style="margin-left:.25rem">
            <input type="date" name="week" class="form-control form-control-sm" style="width:150px"
                   value="${weekStart}">
            <button class="btn btn-sm btn-outline-secondary" type="submit">Go</button>
        </form>
    </div>

    <%-- Actual trips for this week (PRIMARY — real dates from trips table) --%>
    <div class="card">
        <div class="d-flex align-items-center justify-content-between px-3 pt-3 pb-2"
             style="border-bottom:1px solid var(--sb-border)">
            <span style="font-size:.78rem;font-weight:700;color:#94a3b8">
                <i class="bi bi-calendar-check me-1" style="color:#3b82f6"></i>
                ACTUAL TRIPS THIS WEEK &nbsp;–&nbsp;
                <strong style="color:#e2e8f0">${fn:length(weekTrips)}</strong> trip${fn:length(weekTrips) == 1 ? '' : 's'}
            </span>
            <a href="${pageContext.request.contextPath}/trips" class="btn btn-sm btn-outline-secondary" style="font-size:.72rem">
                <i class="bi bi-arrow-right me-1"></i>View All Trips
            </a>
        </div>
        <table class="table table-hover mb-0">
            <thead>
                <tr>
                    <th>Date &amp; Time</th>
                    <th>Driver</th>
                    <th>Route</th>
                    <th>Bus</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
            <c:forEach var="t" items="${weekTrips}">
                <tr>
                    <td style="font-size:.82rem;white-space:nowrap">
                        <time class="fmt-dt" data-dt="${t.startTime}">${t.startTime}</time>
                    </td>
                    <td style="font-weight:600">
                        <i class="bi bi-person-fill me-1" style="color:#60a5fa"></i>${t.driver.name}
                    </td>
                    <td>
                        <div style="font-weight:500">${t.route.routeName}</div>
                        <div style="font-size:.72rem;color:#64748b">
                            ${t.route.startLocation} &rarr; ${t.route.endLocation}
                        </div>
                    </td>
                    <td>
                        <i class="bi bi-bus-front me-1" style="color:#94a3b8"></i>${t.bus.registrationNumber}
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${t.status == 'IN_PROGRESS'}">
                                <span class="badge" style="background:#064e3b;color:#34d399;border-radius:20px">
                                    <i class="bi bi-broadcast-pin me-1"></i>In Progress
                                </span>
                            </c:when>
                            <c:when test="${t.status == 'SCHEDULED'}">
                                <span class="badge" style="background:#1e1b4b;color:#818cf8;border-radius:20px">
                                    <i class="bi bi-clock me-1"></i>Scheduled
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge" style="background:#1c1c1c;color:#6b7280;border-radius:20px">
                                    <i class="bi bi-check2 me-1"></i>Completed
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty weekTrips}">
                <tr>
                    <td colspan="5" class="text-center py-4" style="color:#64748b">
                        <i class="bi bi-calendar-x" style="display:block;font-size:1.6rem;margin-bottom:.4rem"></i>
                        No trips generated yet — publish the week plan below to create them.
                    </td>
                </tr>
            </c:if>
            </tbody>
        </table>
    </div>

    <%-- Schedule plan entries (SECONDARY — admin planning tool, auto-hides once all published) --%>
    <c:if test="${unpublished > 0 or empty weekTrips}">
    <div class="card mt-4">
        <div class="d-flex align-items-center justify-content-between px-3 pt-3 pb-2"
             style="border-bottom:1px solid var(--sb-border)">
            <span style="font-size:.78rem;font-weight:700;color:#94a3b8">
                WEEK PLAN &nbsp;–&nbsp; ${fn:length(entries)} entr${fn:length(entries) == 1 ? 'y' : 'ies'}
                <span style="color:#475569;font-size:.7rem;font-weight:400;margin-left:.4rem">(generates Mon–Fri trips on publish)</span>
            </span>
            <c:choose>
                <c:when test="${unpublished == 0 and fn:length(entries) > 0}">
                    <span class="badge badge-published"><i class="bi bi-check-circle-fill me-1"></i>All Published</span>
                </c:when>
                <c:when test="${unpublished > 0}">
                    <span class="badge badge-unpublished"><i class="bi bi-exclamation-circle-fill me-1"></i>${unpublished} Pending</span>
                </c:when>
            </c:choose>
        </div>
        <table class="table table-hover mb-0">
            <thead>
                <tr>
                    <th>Driver</th>
                    <th>Assigned Route</th>
                    <th>Bus</th>
                    <th>Shift</th>
                    <th>Shift Hours</th>
                    <th>Status</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
            <c:forEach var="ds" items="${entries}">
                <c:set var="shiftCls" value=""/>
                <c:if test="${ds.shiftType == 'Morning'}">  <c:set var="shiftCls" value="shift-morning"/></c:if>
                <c:if test="${ds.shiftType == 'Afternoon'}"><c:set var="shiftCls" value="shift-afternoon"/></c:if>
                <c:if test="${ds.shiftType == 'Shuttle'}">  <c:set var="shiftCls" value="shift-shuttle"/></c:if>
                <tr>
                    <td style="font-weight:600">
                        <i class="bi bi-person-fill me-1" style="color:#60a5fa"></i>${ds.driver.name}
                    </td>
                    <td>
                        <div style="font-weight:500">${ds.route.routeName}</div>
                        <div style="font-size:.72rem;color:#64748b">
                            ${ds.route.startLocation} &rarr; ${ds.route.endLocation}
                        </div>
                    </td>
                    <td>
                        <i class="bi bi-bus-front me-1" style="color:#94a3b8"></i>${ds.bus.registrationNumber}
                    </td>
                    <td>
                        <span class="badge ${shiftCls}" style="border-radius:20px;padding:.3rem .8rem;border:1px solid">${ds.shiftType}</span>
                    </td>
                    <td style="font-family:monospace;font-size:.85rem">
                        <span style="color:#34d399">${ds.shiftStart}</span>
                        &ndash;
                        <span style="color:#f87171">${ds.shiftEnd}</span>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${ds.published}">
                                <span class="badge badge-published" style="border-radius:20px">
                                    <i class="bi bi-check2-circle me-1"></i>Published
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-unpublished" style="border-radius:20px">
                                    <i class="bi bi-clock me-1"></i>Pending
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td class="text-end">
                        <c:if test="${!ds.published}">
                            <a href="${pageContext.request.contextPath}/weekly-schedule/edit?id=${ds.id}&week=${weekStart}"
                               class="btn btn-sm btn-outline-secondary me-1" title="Edit">
                                <i class="bi bi-pencil"></i>
                            </a>
                        </c:if>
                        <a href="${pageContext.request.contextPath}/weekly-schedule/delete?id=${ds.id}&week=${weekStart}"
                           class="btn btn-sm btn-outline-danger"
                           onclick="return confirm('Delete this schedule entry?')" title="Delete">
                            <i class="bi bi-trash"></i>
                        </a>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty entries}">
                <tr>
                    <td colspan="6" class="text-center py-5" style="color:#64748b">
                        <i class="bi bi-calendar-x" style="font-size:2rem;display:block;margin-bottom:.5rem"></i>
                        No schedule entries for this week.
                    </td>
                </tr>
            </c:if>
            </tbody>
        </table>
    </div>
    <p class="mt-3" style="font-size:.72rem;color:#475569">
        <i class="bi bi-info-circle me-1"></i>
        Clicking <strong>Publish Week</strong> creates 5 SCHEDULED trips (Mon–Fri) for each pending entry
        and sends a notification to each assigned driver. Published entries are locked.
    </p>
    </c:if>

</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
// Format ISO datetimes to human-readable (e.g. "Mon 11 May, 12:01")
document.querySelectorAll('time.fmt-dt').forEach(function(el) {
    var raw = el.dataset.dt;
    if (!raw) return;
    var d = new Date(raw.replace('T', ' '));
    if (isNaN(d.getTime())) return;
    el.textContent = d.toLocaleString('en-ZA', {
        weekday:'short', day:'numeric', month:'short',
        hour:'2-digit', minute:'2-digit', hour12:false
    });
});
</script>
</body>
</html>
