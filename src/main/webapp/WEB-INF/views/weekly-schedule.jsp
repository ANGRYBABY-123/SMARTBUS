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

    <%-- Schedule entries table --%>
    <div class="card">
        <div class="d-flex align-items-center justify-content-between px-3 pt-3 pb-2"
             style="border-bottom:1px solid var(--sb-border)">
            <span style="font-size:.78rem;font-weight:700;color:#94a3b8">
                WEEK OF <strong style="color:#e2e8f0">${weekStart}</strong>
                &nbsp;–&nbsp; ${fn:length(entries)} entr${fn:length(entries) == 1 ? 'y' : 'ies'}
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
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
