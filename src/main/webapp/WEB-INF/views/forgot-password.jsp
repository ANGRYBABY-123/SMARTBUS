<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CommuteSafe – Forgot Password</title>
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
.card-body{padding:26px}
.card-title{font-size:1rem;font-weight:800;color:#0d1f38;margin-bottom:6px}
.card-sub{font-size:.82rem;color:#6b7280;margin-bottom:20px;line-height:1.55}
.alert{border-radius:10px;padding:11px 14px;font-size:.82rem;margin-bottom:18px;display:flex;align-items:flex-start;gap:8px}
.alert-error{background:#fff2f2;color:#c0392b;border:1px solid #fcc}
.field{margin-bottom:16px}
.field label{display:block;font-size:.78rem;font-weight:700;color:#374151;margin-bottom:5px;text-transform:uppercase;letter-spacing:.04em}
.field input{width:100%;padding:11px 14px;border:1.5px solid #e5e7eb;border-radius:10px;font-size:.9rem;color:#111;outline:none;transition:border-color .2s,box-shadow .2s}
.field input:focus{border-color:#00c853;box-shadow:0 0 0 3px rgba(0,200,83,.12)}
.field input::placeholder{color:#9ca3af}
.btn-main{width:100%;padding:13px;background:#000;color:#fff;border:none;border-radius:12px;font-size:.95rem;font-weight:800;cursor:pointer;transition:background .2s;margin-top:4px;display:flex;align-items:center;justify-content:center;gap:8px}
.btn-main:hover:not(:disabled){background:#00c853;color:#000}
.btn-main:disabled{background:#d1d5db;color:#9ca3af;cursor:not-allowed}
.back-link{text-align:center;margin-top:16px;font-size:.8rem;color:#9ca3af}
.back-link a{color:#0d1f38;font-weight:700;text-decoration:none}
.back-link a:hover{text-decoration:underline}
.spinner{width:16px;height:16px;border:2px solid rgba(255,255,255,.4);border-top-color:#fff;border-radius:50%;animation:spin .7s linear infinite;display:none;flex-shrink:0}
@keyframes spin{to{transform:rotate(360deg)}}
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
    <div class="brand-tag">Safe, real-time commuting — powered by live GPS</div>
  </div>
  <div class="card-body">
    <div class="card-title">Forgot your password?</div>
    <p class="card-sub">Enter the email on your account and we'll send you a 5-digit verification code.</p>

    <%
        String forgotError = (String) request.getAttribute("forgotError");
        String prevEmail   = request.getParameter("email");
        if (prevEmail == null) prevEmail = "";
        // HTML-escape to prevent XSS (forgotError may contain user-supplied email)
        String forgotErrorEsc = forgotError == null ? null : forgotError
            .replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
        String prevEmailEsc = prevEmail
            .replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    %>
    <% if (forgotErrorEsc != null) { %>
    <div class="alert alert-error"><i class="bi bi-exclamation-triangle-fill" style="flex-shrink:0;margin-top:1px"></i><span><%= forgotErrorEsc %></span></div>
    <% } %>

    <form method="post" action="${pageContext.request.contextPath}/forgot-password" id="fp-form">
      <div class="field">
        <label for="fp-email">Email Address</label>
        <input type="email" id="fp-email" name="email"
               placeholder="you@example.com"
               value="<%= prevEmailEsc %>"
               required autofocus autocomplete="email">
      </div>
      <button type="submit" class="btn-main" id="fp-btn">
        <div class="spinner" id="fp-spinner"></div>
        <span id="fp-label"><i class="bi bi-envelope-fill"></i> Send Verification Code</span>
      </button>
    </form>

    <div class="back-link"><a href="${pageContext.request.contextPath}/users/login"><i class="bi bi-arrow-left"></i> Back to Login</a></div>
  </div>
</div>
<script>
document.getElementById('fp-form').addEventListener('submit', function() {
  var btn = document.getElementById('fp-btn');
  btn.disabled = true;
  document.getElementById('fp-spinner').style.display = 'block';
  document.getElementById('fp-label').textContent = 'Sending…';
});
</script>
</body>
</html>
