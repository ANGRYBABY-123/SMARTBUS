<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CommuteSafe – Verify Login</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{min-height:100vh;background:linear-gradient(145deg,#050c1a 0%,#0d1f38 55%,#0a3d2b 100%);display:flex;align-items:center;justify-content:center;font-family:Segoe UI,system-ui,sans-serif;padding:20px 16px}
.card{background:#fff;border-radius:24px;width:100%;max-width:420px;box-shadow:0 32px 80px rgba(0,0,0,.5);overflow:hidden}
.card-hdr{background:linear-gradient(135deg,#0a0f1e,#0d2137);padding:26px 28px 20px;text-align:center}
.brand-icon{font-size:2rem;color:#00e676}
.brand-name{font-size:1.7rem;font-weight:900;color:#fff;letter-spacing:-.5px;margin-top:6px}
.brand-name span{color:#00e676}
.brand-tag{font-size:.77rem;color:#64748b;margin-top:4px}
.card-body{padding:26px;text-align:center}
.icon{font-size:2.6rem;color:#0d1f38;margin-bottom:10px}
.card-title{font-size:1rem;font-weight:800;color:#0d1f38;margin-bottom:8px}
.subtitle{font-size:.83rem;color:#6b7280;margin-bottom:22px;line-height:1.6}
.subtitle strong{color:#0d1f38}
.alert{border-radius:10px;padding:11px 14px;font-size:.82rem;margin-bottom:16px;display:flex;align-items:flex-start;gap:8px;text-align:left}
.alert-error{background:#fff2f2;color:#c0392b;border:1px solid #fcc}
.code-inputs{display:flex;gap:10px;justify-content:center;margin-bottom:20px}
.code-input{width:52px;height:62px;text-align:center;font-size:1.6rem;font-weight:700;color:#000;border:1.5px solid #e5e7eb;border-radius:12px;outline:none;transition:border-color .2s;caret-color:transparent}
.code-input:focus{border-color:#00c853;box-shadow:0 0 0 3px rgba(0,200,83,.12)}
.btn-main{width:100%;padding:13px;background:#000;color:#fff;border:none;border-radius:12px;font-size:.95rem;font-weight:800;cursor:pointer;transition:background .2s}
.btn-main:hover{background:#00c853;color:#000}
.link-row{margin-top:14px;font-size:.82rem;color:#9ca3af}
.link-row a{color:#0d1f38;font-weight:700;text-decoration:none;display:block;margin-top:8px}
.link-row a:hover{text-decoration:underline}
.badge-role{display:inline-block;background:#f0fdf4;border:1px solid #86efac;color:#166534;border-radius:20px;padding:3px 12px;font-size:.75rem;font-weight:700;margin-bottom:14px;text-transform:uppercase;letter-spacing:.05em}
</style>
</head>
<body>
<div class="card">
  <div class="card-hdr">
    <div class="brand-icon">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="56" height="56" aria-hidden="true">
        <path d="M24 3L41 10.5L41 24C41 34.5 33.5 42.5 24 44.5C14.5 42.5 7 34.5 7 24L7 10.5Z" fill="#00c853"/>
        <path d="M24 8L38 14.5L38 24C38 32.5 32 39.5 24 41.5C16 39.5 10 32.5 10 24L10 14.5Z" fill="rgba(0,0,0,0.1)"/>
        <rect x="13.5" y="22" width="21" height="13" rx="3" fill="white"/>
        <rect x="15" y="17.5" width="18" height="5.5" rx="2.5" fill="rgba(255,255,255,0.93)"/>
        <rect x="15.5" y="23.5" width="5.5" height="4.5" rx="1" fill="#009c3b"/>
        <rect x="23" y="23.5" width="5.5" height="4.5" rx="1" fill="#009c3b"/>
        <circle cx="18" cy="35.5" r="3" fill="#009c3b"/>
        <circle cx="30" cy="35.5" r="3" fill="#009c3b"/>
      </svg>
    </div>
    <div class="brand-name">Commute<span>Safe</span></div>
    <div class="brand-tag">Safe, real-time commuting &mdash; powered by live GPS</div>
  </div>
  <div class="card-body">
    <div class="icon"><i class="bi bi-shield-lock-fill"></i></div>
    <div class="card-title">Two-Factor Verification</div>
    <%
        jakarta.servlet.http.HttpSession sess = request.getSession(false);
        String sentTo  = sess != null ? (String) sess.getAttribute("pendingUserEmail") : null;
        String role    = sess != null ? (String) sess.getAttribute("pendingUserRole")  : null;
        String masked  = null;
        if (sentTo != null) {
            int at = sentTo.indexOf('@');
            if (at > 1) {
                masked = sentTo.substring(0,1) + "***" + sentTo.substring(at);
            } else {
                masked = sentTo;
            }
        }
    %>
    <% if (role != null) { %>
    <div class="badge-role"><i class="bi bi-<%= "DRIVER".equals(role) ? "person-badge" : "person" %>-fill"></i> <%= role.charAt(0) + role.substring(1).toLowerCase() %></div>
    <% } %>
    <p class="subtitle">
      We sent a 6-digit code to<br>
      <strong><%= masked != null ? masked : "your email address" %></strong><br>
      <span style="color:#9ca3af;font-size:.78rem">Valid for 10 minutes. Check your spam folder too.</span>
    </p>

    <% String error = (String) request.getAttribute("error"); %>
    <% if (error != null) { %>
    <div class="alert alert-error"><i class="bi bi-exclamation-triangle-fill" style="flex-shrink:0;margin-top:1px"></i><span><%= error %></span></div>
    <% } %>

    <form method="post" action="${pageContext.request.contextPath}/users/verify-otp" id="verify-form">
      <input type="hidden" name="otp" id="otp-hidden">
      <div class="code-inputs">
        <input type="text" maxlength="1" class="code-input" id="d1" inputmode="numeric" pattern="[0-9]" required autocomplete="off">
        <input type="text" maxlength="1" class="code-input" id="d2" inputmode="numeric" pattern="[0-9]" required autocomplete="off">
        <input type="text" maxlength="1" class="code-input" id="d3" inputmode="numeric" pattern="[0-9]" required autocomplete="off">
        <input type="text" maxlength="1" class="code-input" id="d4" inputmode="numeric" pattern="[0-9]" required autocomplete="off">
        <input type="text" maxlength="1" class="code-input" id="d5" inputmode="numeric" pattern="[0-9]" required autocomplete="off">
        <input type="text" maxlength="1" class="code-input" id="d6" inputmode="numeric" pattern="[0-9]" required autocomplete="off">
      </div>
      <button type="submit" class="btn-main"><i class="bi bi-shield-check"></i> Verify &amp; Sign In</button>
    </form>

    <div class="link-row">
      <a href="${pageContext.request.contextPath}/users/login"><i class="bi bi-arrow-left"></i> Back to login</a>
    </div>
  </div>
</div>
<script>
var inputs = document.querySelectorAll('.code-input');
inputs.forEach(function(inp, i) {
  inp.addEventListener('input', function() {
    inp.value = inp.value.replace(/\D/g,'').slice(0,1);
    if (inp.value && i < inputs.length - 1) inputs[i+1].focus();
  });
  inp.addEventListener('keydown', function(e) {
    if (e.key === 'Backspace' && !inp.value && i > 0) inputs[i-1].focus();
  });
  inp.addEventListener('paste', function(e) {
    e.preventDefault();
    var pasted = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g,'');
    Array.from(pasted).slice(0,6).forEach(function(ch, j) { if (inputs[i+j]) inputs[i+j].value = ch; });
    inputs[Math.min(i + pasted.length, inputs.length - 1)].focus();
  });
});
inputs[0].focus();
document.getElementById('verify-form').addEventListener('submit', function() {
  var code = Array.from(inputs).map(function(inp){ return inp.value; }).join('');
  document.getElementById('otp-hidden').value = code;
});
</script>
</body>
</html>
