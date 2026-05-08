<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><title>Dashboard – SmartBus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container-fluid sb-main">

    <h5 class="fw-bold mb-4"><i class="bi bi-speedometer2 me-2" style="color:#3b82f6"></i>Dashboard</h5>

    <!-- Stat cards -->
    <div class="row g-3 mb-4" id="sb-stats-row">
        <div class="col-6 col-md-3">
            <div class="card p-3 text-center">
                <div style="font-size:2rem;color:#3b82f6"><i class="bi bi-bus-front-fill"></i></div>
                <div style="font-size:1.6rem;font-weight:700">${totalBuses}</div>
                <div style="font-size:.78rem;color:#94a3b8">Total Buses</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card p-3 text-center">
                <div style="font-size:2rem;color:#22c55e"><i class="bi bi-geo-alt-fill"></i></div>
                <div style="font-size:1.6rem;font-weight:700">${activeTripsCount}</div>
                <div style="font-size:.78rem;color:#94a3b8">Active Trips</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card p-3 text-center">
                <div style="font-size:2rem;color:#f59e0b"><i class="bi bi-signpost-split-fill"></i></div>
                <div style="font-size:1.6rem;font-weight:700">${totalRoutes}</div>
                <div style="font-size:.78rem;color:#94a3b8">Routes</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card p-3 text-center">
                <div style="font-size:2rem;color:#a78bfa"><i class="bi bi-people-fill"></i></div>
                <div style="font-size:1.6rem;font-weight:700">${totalUsers}</div>
                <div style="font-size:.78rem;color:#94a3b8">Users</div>
            </div>
        </div>
    </div>

    <!-- Pending Approvals notice -->
    <div id="pending-banner">
    <c:if test="${pendingUsersCount > 0}">
    <div class="alert d-flex align-items-center gap-3 mb-4" style="background:#fff8e1;border:1.5px solid #f59e0b;border-radius:12px;padding:14px 18px">
        <i class="bi bi-clock-history" style="font-size:1.5rem;color:#f57c00;flex-shrink:0"></i>
        <div style="flex:1">
            <div style="font-weight:700;color:#5d4037" id="pending-count-text">
                ${pendingUsersCount} account${pendingUsersCount == 1 ? '' : 's'} waiting for approval
            </div>
            <div style="font-size:.82rem;color:#795548">New users have registered and cannot sign in until you approve them.</div>
        </div>
        <a href="${pageContext.request.contextPath}/users/list" class="btn btn-sm" style="background:#f57c00;color:#fff;border:none;font-weight:600;white-space:nowrap">
            <i class="bi bi-person-check-fill me-1"></i>Review Now
        </a>
    </div>
    </c:if>
    </div>

    <!-- This week's schedule panel -->
    <div class="card mb-4" id="sb-schedule-panel" style="border-color:${unpublishedThisWeek > 0 ? '#f59e0b' : '#334155'}!important">
        <div class="p-3 d-flex justify-content-between align-items-center flex-wrap gap-2" style="border-bottom:1px solid #334155">
            <div>
                <span style="font-weight:600;font-size:.9rem">
                    <i class="bi bi-calendar-week me-2" style="color:#f59e0b"></i>This Week's Schedule
                </span>
                <span style="font-size:.75rem;color:#64748b;margin-left:.5rem">${weekStart} (Mon–Fri)</span>
            </div>
            <div class="d-flex gap-2 align-items-center">
                <c:choose>
                    <c:when test="${unpublishedThisWeek > 0}">
                        <span class="badge" style="background:#78350f;color:#fbbf24;font-size:.75rem">
                            ${unpublishedThisWeek} unpublished entr${unpublishedThisWeek == 1 ? 'y' : 'ies'}
                        </span>
                        <form method="post" action="${pageContext.request.contextPath}/weekly-schedule/publish"
                              onsubmit="return confirm('Publish this week\'s schedule? Trips (Mon–Fri) will be created and drivers notified.')">
                            <input type="hidden" name="weekStartDate" value="${weekStart}">
                            <button type="submit" class="btn btn-sm" style="background:#16a34a;color:#fff;border:none;font-weight:600">
                                <i class="bi bi-send-fill me-1"></i>Publish Now
                            </button>
                        </form>
                    </c:when>
                    <c:when test="${totalThisWeek > 0}">
                        <span class="badge" style="background:#064e3b;color:#34d399;font-size:.75rem">
                            <i class="bi bi-check-circle-fill me-1"></i>All published
                        </span>
                    </c:when>
                    <c:otherwise>
                        <span style="font-size:.8rem;color:#64748b">No entries yet for this week.</span>
                    </c:otherwise>
                </c:choose>
                <a href="${pageContext.request.contextPath}/weekly-schedule/list" class="btn btn-sm btn-outline-secondary">
                    <i class="bi bi-pencil me-1"></i>Edit Schedule
                </a>
            </div>
        </div>
        <c:if test="${totalThisWeek == 0}">
        <div class="p-3" style="font-size:.84rem;color:#64748b">
            <i class="bi bi-info-circle me-1"></i>
            Add driver entries under <a href="${pageContext.request.contextPath}/weekly-schedule/new" style="color:#3b82f6">Weekly Schedule</a>
            and hit <strong>Publish</strong> — trips for Mon–Fri will be auto-created and drivers notified instantly.
        </div>
        </c:if>
    </div>

    <!-- Active trips table -->
    <div class="card" id="sb-active-trips">
        <div class="p-3 border-bottom" style="border-color:#334155!important">
            <span style="font-weight:600;font-size:.9rem"><i class="bi bi-activity me-2" style="color:#22c55e"></i>Active Trips</span>
        </div>
        <table class="table table-hover mb-0">
            <thead>
                <tr><th>#</th><th>Route</th><th>Driver</th><th>Bus</th><th>Status</th><th>Track</th></tr>
            </thead>
            <tbody>
            <c:forEach var="t" items="${activeTripsList}">
                <tr>
                    <td style="color:#64748b;font-size:.8rem">${t.tripId}</td>
                    <td>${t.route.routeName}</td>
                    <td>${t.driver.name}</td>
                    <td style="font-family:monospace;color:#93c5fd">${t.bus.registrationNumber}</td>
                    <td><span class="badge bg-success">${t.status}</span></td>
                    <td><a href="${pageContext.request.contextPath}/tracking/view?tripId=${t.tripId}" class="btn btn-sm btn-outline-primary"><i class="bi bi-map"></i></a></td>
                </tr>
            </c:forEach>
            <c:if test="${empty activeTripsList}">
                <tr><td colspan="6" class="text-center py-4" style="color:#64748b">No active trips right now.</td></tr>
            </c:if>
            </tbody>
        </table>
    </div>

</div>
</body>
<script>
// ── Auto-refresh: swap stats + active trips every 15s without reloading page ──
(function() {
    // Exclude pending-banner from the DOM swap — the dedicated poller manages it
    const SWAP_IDS = ['sb-stats-row', 'sb-schedule-panel', 'sb-active-trips'];
    async function autoRefresh() {
        try {
            const res = await fetch(location.href, { credentials: 'same-origin' });
            if (!res.ok) return;
            const doc = new DOMParser().parseFromString(await res.text(), 'text/html');
            SWAP_IDS.forEach(id => {
                const fresh = doc.getElementById(id);
                const curr  = document.getElementById(id);
                if (fresh && curr) curr.outerHTML = fresh.outerHTML;
            });
        } catch (e) { /* silent */ }
    }
    setInterval(autoRefresh, 15000);
})();

// ── Live pending-approvals banner + 2-second beep ──
(function () {
    var ctxPath = '${pageContext.request.contextPath}';
    // Start at -1 so the very first poll always renders the banner and
    // triggers a beep if there are already pending users on load.
    var lastCount = -1;

    function beep() {
        try {
            var ac = new (window.AudioContext || window.webkitAudioContext)();
            var osc  = ac.createOscillator();
            var gain = ac.createGain();
            osc.connect(gain);
            gain.connect(ac.destination);
            osc.type = 'sine';
            osc.frequency.setValueAtTime(880, ac.currentTime);
            gain.gain.setValueAtTime(0.6, ac.currentTime);
            gain.gain.linearRampToValueAtTime(0, ac.currentTime + 2);
            osc.start(ac.currentTime);
            osc.stop(ac.currentTime + 2);
        } catch (e) { /* AudioContext blocked until user gesture – silent */ }
    }

    function renderBanner(count) {
        var banner = document.getElementById('pending-banner');
        if (!banner) return;
        if (count > 0) {
            banner.innerHTML =
                '<div class="alert d-flex align-items-center gap-3 mb-4"'
                + ' style="background:#fff8e1;border:1.5px solid #f59e0b;border-radius:12px;padding:14px 18px">'
                + '<i class="bi bi-clock-history" style="font-size:1.5rem;color:#f57c00;flex-shrink:0"></i>'
                + '<div style="flex:1">'
                + '<div style="font-weight:700;color:#5d4037">'
                + count + ' account' + (count === 1 ? '' : 's') + ' waiting for approval'
                + '</div>'
                + '<div style="font-size:.82rem;color:#795548">'
                + 'New users have registered and cannot sign in until you approve them.</div>'
                + '</div>'
                + '<a href="' + ctxPath + '/users/list" class="btn btn-sm"'
                + ' style="background:#f57c00;color:#fff;border:none;font-weight:600;white-space:nowrap">'
                + '<i class="bi bi-person-check-fill me-1"></i>Review Now</a>'
                + '</div>';
        } else {
            banner.innerHTML = '';
        }
    }

    async function pollPending() {
        try {
            var res = await fetch(ctxPath + '/api/pending-count', {
                credentials: 'same-origin',
                cache: 'no-store'
            });
            if (!res.ok) return;
            var data = await res.json();
            var count = typeof data.count === 'number' ? data.count : 0;
            if (count > lastCount && lastCount !== -1) {
                // New registrations arrived since last check
                beep();
            }
            // Always re-render banner so it's always in sync (handles lastCount === -1 on first poll too)
            renderBanner(count);
            lastCount = count;
        } catch (e) { /* silent */ }
    }

    // Fire immediately on page load, then every 5 seconds
    pollPending();
    setInterval(pollPending, 5000);
})();
</script>
</html>
