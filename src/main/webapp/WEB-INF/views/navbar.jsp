<%@ page contentType="text/html;charset=UTF-8" %><%@ taglib prefix="c" uri="jakarta.tags.core" %><style>
/* ============================================================
   SmartBus Admin – Global Dark Theme  (injected by navbar.jsp)
   ============================================================ */
:root{--sb-bg:#0a0f1e;--sb-surface:#0f172a;--sb-elevated:#1e293b;--sb-raised:#263248;--sb-border:#334155;--sb-text:#e2e8f0;--sb-muted:#94a3b8;--sb-accent:#3b82f6;--sb-accent-h:#2563eb;--sb-danger:#ef4444;}
html,body{background:var(--sb-bg)!important;color:var(--sb-text)!important;min-height:100vh;}
.sb-main{padding-top:74px;padding-left:1.5rem;padding-right:1.5rem;padding-bottom:2.5rem;}
.card{background:var(--sb-elevated)!important;border:1px solid var(--sb-border)!important;border-radius:10px!important;box-shadow:0 2px 10px rgba(0,0,0,.4)!important;}
.table{--bs-table-bg:transparent;--bs-table-color:var(--sb-text);--bs-table-border-color:var(--sb-border);--bs-table-hover-bg:var(--sb-raised);color:var(--sb-text);}
.table thead th{background:var(--sb-surface)!important;color:var(--sb-muted)!important;border-color:var(--sb-border)!important;font-size:.71rem;text-transform:uppercase;letter-spacing:.09em;font-weight:700;padding:.8rem 1rem;}
.table tbody td{border-color:var(--sb-border)!important;color:var(--sb-text);padding:.75rem 1rem;vertical-align:middle;}
.table-hover tbody tr:hover td{background:var(--sb-raised)!important;}
.form-control,.form-select{background:var(--sb-raised)!important;color:var(--sb-text)!important;border:1px solid var(--sb-border)!important;}
.form-control::placeholder{color:var(--sb-muted);}
.form-control:focus,.form-select:focus{background:var(--sb-raised)!important;color:var(--sb-text)!important;border-color:var(--sb-accent)!important;box-shadow:0 0 0 3px rgba(59,130,246,.2)!important;}
.form-select option{background:var(--sb-raised);color:var(--sb-text);}
.form-label{color:var(--sb-muted)!important;font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.06em;margin-bottom:.35rem;}
.btn-primary{background:var(--sb-accent)!important;border-color:var(--sb-accent)!important;font-weight:500;}
.btn-primary:hover{background:var(--sb-accent-h)!important;border-color:var(--sb-accent-h)!important;}
.btn-outline-secondary{color:var(--sb-muted)!important;border-color:var(--sb-border)!important;}
.btn-outline-secondary:hover{background:var(--sb-raised)!important;color:var(--sb-text)!important;}
.btn-outline-primary{color:var(--sb-accent)!important;border-color:var(--sb-accent)!important;}
.btn-outline-primary:hover{background:var(--sb-accent)!important;color:#fff!important;}
.btn-outline-danger{color:var(--sb-danger)!important;border-color:var(--sb-danger)!important;}
.btn-outline-danger:hover{background:var(--sb-danger)!important;color:#fff!important;}
.badge.bg-secondary{background:#475569!important;}.badge.bg-primary{background:#1d4ed8!important;}
.badge.bg-success{background:#16a34a!important;}.badge.bg-danger{background:#dc2626!important;}
.badge.bg-warning{background:#d97706!important;color:#fff!important;}
hr{border-color:var(--sb-border)!important;}
/* Topnav */
.sb-topnav{position:fixed;top:0;left:0;right:0;z-index:1040;height:58px;background:var(--sb-surface);border-bottom:1px solid var(--sb-border);display:flex;align-items:center;padding:0 1.25rem;gap:.15rem;}
.sb-brand{display:flex;align-items:center;gap:.45rem;color:#fff;text-decoration:none;font-weight:700;font-size:.92rem;margin-right:.45rem;white-space:nowrap;}
.sb-brand i{color:var(--sb-accent);font-size:1.15rem;}
.sb-brand .sub{font-size:.58rem;color:#475569;font-weight:400;letter-spacing:.14em;margin-left:2px;}
.sb-div{width:1px;height:26px;background:var(--sb-border);margin:0 .5rem;flex-shrink:0;}
.sb-lnk{display:flex;align-items:center;gap:.28rem;color:var(--sb-muted);text-decoration:none;font-size:.8rem;font-weight:500;padding:.3rem .55rem;border-radius:6px;transition:background .15s,color .15s;white-space:nowrap;}
.sb-lnk i{font-size:.82rem;}.sb-lnk:hover{color:var(--sb-text);background:var(--sb-elevated);}.sb-lnk.active{color:#fff;background:rgba(59,130,246,.2);}
.sb-sp{flex:1;}
.sb-chip{display:flex;align-items:center;gap:.3rem;background:var(--sb-elevated);border:1px solid var(--sb-border);border-radius:20px;padding:.2rem .65rem;font-size:.75rem;color:var(--sb-muted);margin-right:.4rem;}
.sb-chip i{color:var(--sb-accent);}
.sb-dash{display:flex;align-items:center;gap:.3rem;color:var(--sb-muted);text-decoration:none;font-size:.8rem;font-weight:500;padding:.3rem .65rem;border-radius:6px;border:1px solid var(--sb-border);transition:all .15s;white-space:nowrap;margin-right:.3rem;}
.sb-dash:hover{color:#fff;background:var(--sb-elevated);border-color:var(--sb-muted);}
.sb-out{display:flex;align-items:center;gap:.3rem;color:#fff;text-decoration:none;font-size:.8rem;font-weight:500;padding:.3rem .65rem;border-radius:6px;background:#dc2626;transition:background .15s;white-space:nowrap;}
.sb-out:hover{background:#b91c1c;}</style>
<%String _u=request.getRequestURI();
String _ua=_u.contains("/users")?"active":"";
String _ba=_u.contains("/buses")?"active":"";
String _ra=_u.contains("/routes")?"active":"";
String _ta=_u.contains("/trips")?"active":"";
String _sa=_u.contains("/schedules")?"active":"";
%><nav class="sb-topnav">
    <a href="${pageContext.request.contextPath}/dashboard" class="sb-brand">
        <i class="bi bi-bus-front-fill"></i><span>SmartBus</span><span class="sub">ADMIN</span>
    </a>
    <div class="sb-div"></div>
    <a href="${pageContext.request.contextPath}/users/list"     class="sb-lnk <%=_ua%>"><i class="bi bi-people-fill"></i>Personnel</a>
    <a href="${pageContext.request.contextPath}/buses/list"     class="sb-lnk <%=_ba%>"><i class="bi bi-bus-front"></i>Fleet</a>
    <a href="${pageContext.request.contextPath}/routes/list"    class="sb-lnk <%=_ra%>"><i class="bi bi-map-fill"></i>Routes</a>
    <a href="${pageContext.request.contextPath}/trips/list"     class="sb-lnk <%=_ta%>"><i class="bi bi-signpost-split-fill"></i>Trip&nbsp;Dispatch</a>
    <a href="${pageContext.request.contextPath}/schedules/list" class="sb-lnk <%=_sa%>"><i class="bi bi-calendar3"></i>Schedules</a>
    <div class="sb-sp"></div>
    <c:if test="${not empty sessionScope.loggedUser}">
        <div class="sb-chip"><i class="bi bi-person-circle"></i>${sessionScope.loggedUser.name}</div>
    </c:if>
    <a href="${pageContext.request.contextPath}/dashboard"   class="sb-dash"><i class="bi bi-speedometer2"></i>Dashboard</a>
    <a href="${pageContext.request.contextPath}/users/logout" class="sb-out"><i class="bi bi-box-arrow-right"></i>Sign&nbsp;Out</a>
</nav>
