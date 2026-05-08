<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SmartBus – Reset Password</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        * { box-sizing: border-box; }
        body {
            min-height: 100vh; margin: 0;
            background: linear-gradient(135deg, #000 0%, #0d1b2a 60%, #1a3c5e 100%);
            display: flex; align-items: flex-start; justify-content: center;
            font-family: 'Segoe UI', sans-serif;
            padding: 40px 12px;
        }
        .auth-card {
            background: #fff; border-radius: 20px; padding: 32px 28px;
            width: 100%; max-width: 440px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.4);
        }
        .brand { text-align: center; margin-bottom: 24px; }
        .brand .logo { font-size: 1.8rem; font-weight: 900; color: #000; letter-spacing: -1px; }
        .brand .logo span { color: #00c853; }
        .form-label { font-size: 0.82rem; font-weight: 600; color: #444; margin-bottom: 4px; }
        .form-control {
            border-radius: 10px; border: 1.5px solid #e0e0e0;
            padding: 10px 14px; font-size: 0.9rem; transition: border-color 0.2s;
        }
        .form-control:focus { border-color: #000; box-shadow: 0 0 0 3px rgba(0,0,0,0.08); }
        .btn-submit {
            background: #000; color: #fff; border: none; border-radius: 12px;
            width: 100%; padding: 13px; font-size: 0.95rem; font-weight: 800;
            cursor: pointer; margin-top: 8px; transition: background 0.2s;
        }
        .btn-submit:hover { background: #00c853; color: #000; }
        .alert-box { border-radius: 10px; padding: 10px 14px; font-size: 0.82rem; margin-bottom: 16px; }
        .alert-error   { background: #fff2f2; color: #c0392b; border: 1px solid #f5c6cb; }
        .alert-success { background: #f0fff4; color: #1a7a3a; border: 1px solid #b2dfdb; }
        .pw-strength { font-size: 0.75rem; margin-top: 4px; height: 16px; }
    </style>
</head>
<body>
<div class="auth-card">
    <div class="brand">
        <div class="logo"><i class="bi bi-bus-front-fill" style="color:#00c853"></i> Smart<span>Bus</span></div>
    </div>

    <% String tokenError = (String) request.getAttribute("tokenError"); %>
    <% String formError  = (String) request.getAttribute("error"); %>

    <% if (tokenError != null) { %>
    <!-- Session not verified -->
    <div class="alert-box alert-error">
        <i class="bi bi-x-circle-fill me-2"></i><%= tokenError %>
    </div>
    <p style="font-size:.85rem;color:#555;margin-bottom:16px">
        Please request a new reset code.
    </p>
    <a href="${pageContext.request.contextPath}/forgot-password"
       class="btn-submit" style="display:block;text-align:center;text-decoration:none;padding:13px">
        <i class="bi bi-arrow-left me-1"></i>Request New Code
    </a>

    <% } else { %>
    <!-- Code verified — show the reset form -->
    <h5 class="fw-bold mb-1" style="font-size:1.1rem">Choose a new password</h5>
    <p style="font-size:.82rem;color:#888;margin-bottom:20px">
        Must be at least 6 characters.
    </p>

    <% if (formError != null) { %>
    <div class="alert-box alert-error"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= formError %></div>
    <% } %>

    <form method="post" action="${pageContext.request.contextPath}/reset-password" id="reset-form">

        <div class="mb-3">
            <label class="form-label">New Password</label>
            <input type="password" name="newPassword" id="new-pw" class="form-control"
                   required minlength="6" placeholder="At least 6 characters"
                   autocomplete="new-password">
            <div class="pw-strength" id="pw-strength"></div>
        </div>
        <div class="mb-4">
            <label class="form-label">Confirm New Password</label>
            <input type="password" name="confirmPassword" id="confirm-pw" class="form-control"
                   required placeholder="Repeat your password"
                   autocomplete="new-password">
            <div id="match-msg" style="font-size:.78rem;margin-top:4px;height:16px;"></div>
        </div>

        <button type="submit" class="btn-submit" id="submit-btn">
            <i class="bi bi-shield-lock-fill me-1"></i>Reset Password
        </button>
    </form>

    <% } %>

    <div style="text-align:center;margin-top:18px;font-size:.8rem;color:#aaa;">
        <a href="${pageContext.request.contextPath}/users/login" style="color:#555;text-decoration:none;">
            <i class="bi bi-arrow-left me-1"></i>Back to Login
        </a>
    </div>
</div>

<script>
const newPw    = document.getElementById('new-pw');
const confirmPw = document.getElementById('confirm-pw');
const matchMsg = document.getElementById('match-msg');
const submitBtn = document.getElementById('submit-btn');
const strength = document.getElementById('pw-strength');

if (newPw) {
    newPw.addEventListener('input', function() {
        const v = this.value;
        if (!v) { strength.textContent = ''; return; }
        if (v.length < 6)       { strength.style.color = '#c0392b'; strength.textContent = 'Too short'; }
        else if (v.length < 10) { strength.style.color = '#e67e22'; strength.textContent = 'Moderate'; }
        else                    { strength.style.color = '#1a7a3a'; strength.textContent = 'Strong'; }
        checkMatch();
    });
}

if (confirmPw) {
    confirmPw.addEventListener('input', checkMatch);
}

function checkMatch() {
    if (!confirmPw || !confirmPw.value) { matchMsg.textContent = ''; return; }
    if (newPw.value === confirmPw.value) {
        matchMsg.style.color = '#1a7a3a';
        matchMsg.textContent = '✓ Passwords match';
        if (submitBtn) submitBtn.disabled = false;
    } else {
        matchMsg.style.color = '#c0392b';
        matchMsg.textContent = '✗ Passwords do not match';
        if (submitBtn) submitBtn.disabled = true;
    }
}
</script>
</body>
</html>
