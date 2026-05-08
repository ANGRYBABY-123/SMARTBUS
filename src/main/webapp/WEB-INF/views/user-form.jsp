<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${empty user ? 'Register User' : 'Edit User'} – SmartBus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>
<div class="container sb-main" style="max-width:560px">
    <div class="mb-3">
        <a href="${pageContext.request.contextPath}/users/list"
           style="color:#64748b;text-decoration:none;font-size:.82rem">
            <i class="bi bi-arrow-left me-1"></i>Back to Personnel Directory
        </a>
    </div>
    <h5 class="fw-bold mb-4">
        <i class="bi bi-${empty user ? 'person-plus-fill' : 'person-gear'} me-2" style="color:#3b82f6"></i>
        ${empty user ? 'Register New User' : 'Edit User Record'}
    </h5>
    <div class="card p-4">
        <form method="post" action="${pageContext.request.contextPath}/users/save" novalidate>
            <input type="hidden" name="userId" value="${user.userId}">

            <div class="mb-3">
                <label class="form-label">Full Name</label>
                <input type="text" name="name" class="form-control"
                       value="${user.name}" placeholder="Enter full name" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Email Address</label>
                <input type="email" name="email" class="form-control"
                       value="${user.email}" placeholder="user@smartbus.com" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Password
                    <c:if test="${not empty user}">
                        <span style="color:#64748b;text-transform:none;font-size:.71rem;font-weight:400;letter-spacing:0">
                            (leave blank to keep current)
                        </span>
                    </c:if>
                </label>
                <input type="password" name="password" class="form-control"
                       placeholder="${empty user ? 'Set a strong password' : '••••••••'}"
                       ${empty user ? 'required' : ''}>
            </div>

            <div class="mb-3">
                <label class="form-label">System Role</label>
                <select name="role" id="roleSelect" class="form-select" required
                        onchange="toggleDriverFields()">
                    <option value="">-- Select Role --</option>
                    <option value="ADMIN"     ${user.role=='ADMIN'    ?'selected':''}>Administrator</option>
                    <option value="DRIVER"    ${user.role=='DRIVER'   ?'selected':''}>Driver</option>
                    <option value="PASSENGER" ${user.role=='PASSENGER'?'selected':''}>Passenger</option>
                </select>
            </div>

            <div id="driverRegGroup" style="display:none" class="mb-3">
                <label class="form-label">Licence Number</label>
                <input type="text" name="registrationNumber" class="form-control"
                       value="${user.registrationNumber}"
                       placeholder="e.g. DRV-0042"
                       style="text-transform:uppercase">
                <div style="color:#64748b;font-size:.73rem;margin-top:.3rem">
                    <i class="bi bi-info-circle me-1"></i>
                    Must be unique across all drivers. Auto-generated from email if left blank.
                </div>
            </div>

            <hr>
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary px-4">
                    <i class="bi bi-check-lg me-1"></i>${empty user ? 'Register User' : 'Save Changes'}
                </button>
                <a href="${pageContext.request.contextPath}/users/list"
                   class="btn btn-outline-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>
<script>
function toggleDriverFields() {
    var role = document.getElementById('roleSelect').value;
    document.getElementById('driverRegGroup').style.display = (role === 'DRIVER') ? 'block' : 'none';
}
toggleDriverFields();
</script>
</body>
</html>
