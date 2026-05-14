<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><title>Personnel Directory – CommuteSafe</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        #confirmModal .modal-header { border-bottom: none; padding-bottom: 0; }
        #confirmModal .modal-footer { border-top: none; padding-top: 0; }
        #confirmModal .modal-icon { font-size: 2.4rem; }
    </style>
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container-fluid sb-main">
    <!-- ── Pending Approvals Panel ── -->
    <c:if test="${not empty pendingUsers}">
    <div class="card mb-4 border-warning">
        <div class="card-header d-flex align-items-center gap-2" style="background:#fff8e1; border-bottom:1px solid #f9a825;">
            <i class="bi bi-clock-history" style="color:#f57c00; font-size:1.2rem;"></i>
            <span class="fw-bold" style="color:#5d4037;">Pending Approvals</span>
            <span class="badge rounded-pill ms-1" style="background:#f57c00;">${fn:length(pendingUsers)}</span>
        </div>
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-warning" style="font-size:0.82rem;">
                    <tr><th>#</th><th>Name</th><th>Email</th><th>Role</th><th>Actions</th></tr>
                </thead>
                <tbody>
                <c:forEach var="u" items="${pendingUsers}" varStatus="s">
                    <tr>
                        <td>${s.count}</td>
                        <td><i class="bi bi-person-fill me-1 text-muted"></i>${u.name}</td>
                        <td>${u.email}</td>
                        <td>
                            <c:choose>
                                <c:when test="${u.role == 'DRIVER'}"><span class="badge text-bg-info"><i class="bi bi-bus-front-fill me-1"></i>Driver</span></c:when>
                                <c:otherwise><span class="badge text-bg-secondary"><i class="bi bi-person-fill me-1"></i>Passenger</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <button type="button" class="btn btn-success btn-sm me-1"
                               onclick="showConfirm('Approve ${u.name}?', 'Are you sure you want to approve this account? They will be able to sign in immediately.', 'success', '${pageContext.request.contextPath}/users/approve?id=${u.userId}')">
                                <i class="bi bi-check-circle-fill me-1"></i>Approve
                            </button>
                            <button type="button" class="btn btn-danger btn-sm"
                               onclick="showConfirm('Reject ${u.name}?', 'This will permanently delete their account. This action cannot be undone.', 'danger', '${pageContext.request.contextPath}/users/reject?id=${u.userId}')">
                                <i class="bi bi-x-circle-fill me-1"></i>Reject
                            </button>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    </c:if>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 class="fw-bold mb-0">
            <i class="bi bi-people-fill me-2" style="color:#3b82f6"></i>Personnel Directory
        </h5>
        <a href="${pageContext.request.contextPath}/users/new" class="btn btn-primary btn-sm">
            <i class="bi bi-person-plus-fill me-1"></i>Register User
        </a>
    </div>
    <form class="d-flex gap-2 mb-3" method="get" action="${pageContext.request.contextPath}/users/list">
        <input type="text" name="search" class="form-control form-control-sm"
               style="max-width:320px" placeholder="Search by name or email…" value="${param.search}">
        <button class="btn btn-sm btn-outline-secondary"><i class="bi bi-search me-1"></i>Search</button>
    </form>
    <div class="card">
        <table class="table table-hover mb-0">
            <thead>
                <tr>
                    <th>#</th><th>Full Name</th><th>Email Address</th><th>System Role</th><th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <c:forEach var="u" items="${users}">
                <tr>
                    <td style="color:#64748b;font-size:.8rem">${u.userId}</td>
                    <td style="font-weight:500">${u.name}</td>
                    <td style="color:#94a3b8">${u.email}</td>
                    <td>
                        <c:choose>
                            <c:when test="${u.role=='ADMIN'}">
                                <span class="badge" style="background:#7c3aed">Administrator</span>
                            </c:when>
                            <c:when test="${u.role=='DRIVER'}">
                                <span class="badge" style="background:#0369a1">Driver</span>
                            </c:when>
                            <c:when test="${u.role=='PASSENGER'}">
                                <span class="badge" style="background:#059669">Passenger</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-secondary">${u.role}</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <a href="${pageContext.request.contextPath}/users/edit?id=${u.userId}"
                           class="btn btn-sm btn-outline-primary" title="Edit record"><i class="bi bi-pencil"></i></a>
                        <c:if test="${u.role != 'ADMIN'}">
                        <button type="button" class="btn btn-sm btn-outline-danger ms-1" title="Delete user"
                           onclick="showConfirm('Delete ${u.name}?', 'This will permanently remove the user. This action cannot be undone.', 'danger', '${pageContext.request.contextPath}/users/delete?id=${u.userId}')">
                            <i class="bi bi-trash"></i>
                        </button>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty users}">
                <tr><td colspan="5" class="text-center py-4" style="color:#64748b">No personnel records found.</td></tr>
            </c:if>
            </tbody>
        </table>
    </div>
</div>

<!-- Confirm Modal -->
<div class="modal fade" id="confirmModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width:420px">
        <div class="modal-content border-0 shadow">
            <div class="modal-header pt-4 px-4">
                <div id="confirmIcon" class="modal-icon me-3"></div>
                <h5 class="modal-title fw-bold" id="confirmTitle"></h5>
            </div>
            <div class="modal-body px-4 pb-2" id="confirmBody" style="color:#555;font-size:.95rem"></div>
            <div class="modal-footer px-4 pb-4 gap-2">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <a id="confirmOkBtn" href="#" class="btn">Confirm</a>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function showConfirm(title, body, type, url) {
    var modal = document.getElementById('confirmModal');
    document.getElementById('confirmTitle').textContent = title;
    document.getElementById('confirmBody').textContent = body;
    var btn = document.getElementById('confirmOkBtn');
    var icon = document.getElementById('confirmIcon');
    btn.href = url;
    if (type === 'danger') {
        btn.className = 'btn btn-danger';
        btn.textContent = 'Delete';
        icon.innerHTML = '<i class="bi bi-exclamation-triangle-fill text-danger"></i>';
    } else if (type === 'success') {
        btn.className = 'btn btn-success';
        btn.textContent = 'Approve';
        icon.innerHTML = '<i class="bi bi-check-circle-fill text-success"></i>';
    } else {
        btn.className = 'btn btn-primary';
        btn.textContent = 'Confirm';
        icon.innerHTML = '<i class="bi bi-question-circle-fill text-primary"></i>';
    }
    new bootstrap.Modal(modal).show();
}
</script>
</body>
</html>
