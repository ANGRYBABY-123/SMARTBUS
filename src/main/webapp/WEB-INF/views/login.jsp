<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SmartBus – Sign In</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        * { box-sizing: border-box; }
        body {
            min-height: 100vh; margin: 0;
            background: linear-gradient(135deg, #000 0%, #0d1b2a 60%, #1a3c5e 100%);
            display: flex; align-items: flex-start; justify-content: center;
            font-family: 'Segoe UI', sans-serif;
            padding: 20px 12px;
        }
        .auth-card {
            background: #fff; border-radius: 20px; padding: 32px 28px;
            width: 100%; max-width: 460px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.4);
        }
        .brand { text-align: center; margin-bottom: 24px; }
        .brand .logo { font-size: 2rem; font-weight: 900; color: #000; letter-spacing: -1px; }
        .brand .logo span { color: #00c853; }
        .brand .tagline { font-size: 0.82rem; color: #888; margin-top: 4px; }
        .tabs { display: flex; gap: 0; border-radius: 12px; overflow: hidden; border: 1.5px solid #e0e0e0; margin-bottom: 24px; }
        .tab-btn {
            flex: 1; padding: 10px; font-size: 0.875rem; font-weight: 700;
            background: #fff; border: none; cursor: pointer; color: #666;
            transition: all 0.2s;
        }
        .tab-btn.active { background: #000; color: #fff; }
        .form-section { display: none; }
        .form-section.active { display: block; }
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
        .role-select { display: flex; gap: 8px; margin-bottom: 16px; }
        .role-opt {
            flex: 1; padding: 10px 6px; text-align: center; border: 1.5px solid #e0e0e0;
            border-radius: 10px; cursor: pointer; font-size: 0.82rem; font-weight: 600; color: #666;
            transition: all 0.15s;
        }
        .role-opt.selected, .role-opt:hover { border-color: #000; background: #000; color: #fff; }
        .role-opt i { display: block; font-size: 1.3rem; margin-bottom: 4px; }
        .forgot-link { font-size: 0.8rem; color: #888; text-decoration: none; }
        .forgot-link:hover { color: #000; }
        .alert-box { border-radius: 10px; padding: 10px 14px; font-size: 0.82rem; margin-bottom: 16px; }
        .alert-error { background: #fff2f2; color: #c0392b; border: 1px solid #f5c6cb; }
        .alert-success { background: #f0fff4; color: #1a7a3a; border: 1px solid #b2dfdb; }
        #forgot-panel { display: none; margin-top: 12px; background: #f8fafc; border-radius: 12px; padding: 16px; }
        #forgot-panel.show { display: block; }
        #forgot-panel p { font-size: 0.82rem; color: #555; margin-bottom: 10px; }
    </style>
</head>
<body>
<div class="auth-card">
    <div class="brand">
        <div class="logo"><i class="bi bi-bus-front-fill" style="color:#00c853"></i> Smart<span>Bus</span></div>
        <div class="tagline">Real-time bus tracking & AI assistant</div>
    </div>

    <% if (request.getAttribute("error") != null) { %>
    <div class="alert-box alert-error"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= request.getAttribute("error") %></div>
    <% } %>
    <% if (request.getAttribute("success") != null) { %>
    <div class="alert-box alert-success"><i class="bi bi-check-circle-fill me-2"></i><%= request.getAttribute("success") %></div>
    <% } %>

    <!-- Tabs -->
    <div class="tabs">
        <button class="tab-btn active" onclick="showTab('login')">Sign In</button>
        <button class="tab-btn" onclick="showTab('register')" id="tab-register">Register</button>
    </div>

    <!-- ── Login Form ── -->
    <div class="form-section active" id="section-login">

        <!-- Google Sign-In (top) -->
        <a href="${pageContext.request.contextPath}/oauth/google/init"
           style="display:flex;align-items:center;justify-content:center;gap:10px;padding:11px;border:1.5px solid #e0e0e0;border-radius:10px;background:#fff;color:#333;text-decoration:none;font-size:0.9rem;font-weight:600;transition:border-color .2s;margin-bottom:16px;"
           onmouseover="this.style.borderColor='#4285F4'" onmouseout="this.style.borderColor='#e0e0e0'">
            <svg width="18" height="18" viewBox="0 0 48 48"><path fill="#4285F4" d="M45.12 24.5c0-1.56-.14-3.06-.4-4.5H24v8.51h11.84c-.51 2.75-2.06 5.08-4.39 6.64v5.52h7.11c4.16-3.83 6.56-9.47 6.56-16.17z"/><path fill="#34A853" d="M24 46c5.94 0 10.92-1.97 14.56-5.33l-7.11-5.52c-1.97 1.32-4.49 2.1-7.45 2.1-5.73 0-10.58-3.87-12.31-9.07H4.34v5.7C7.96 41.07 15.4 46 24 46z"/><path fill="#FBBC05" d="M11.69 28.18C11.25 26.86 11 25.45 11 24s.25-2.86.69-4.18v-5.7H4.34C2.85 17.09 2 20.45 2 24c0 3.55.85 6.91 2.34 9.88l7.35-5.7z"/><path fill="#EA4335" d="M24 10.75c3.23 0 6.13 1.11 8.41 3.29l6.31-6.31C34.91 4.18 29.93 2 24 2 15.4 2 7.96 6.93 4.34 14.12l7.35 5.7c1.73-5.2 6.58-9.07 12.31-9.07z"/></svg>
            Login with Google
        </a>

        <!-- OR divider -->
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:16px;">
            <hr style="flex:1;border:none;border-top:1px solid #e0e0e0;margin:0;">
            <span style="color:#aaa;font-size:0.78rem;white-space:nowrap;">OR</span>
            <hr style="flex:1;border:none;border-top:1px solid #e0e0e0;margin:0;">
        </div>

        <form method="post" action="${pageContext.request.contextPath}/users/login">
            <div class="mb-3">
                <label class="form-label">E-Mail</label>
                <input type="email" name="email" class="form-control" required autofocus placeholder="you@example.com">
            </div>
            <div class="mb-3">
                <label class="form-label">Password</label>
                <input type="password" name="password" class="form-control" required placeholder="••••••••">
            </div>
            <div class="mb-3 form-check">
                <input type="checkbox" class="form-check-input" name="rememberMe" id="rememberMe" value="true">
                <label class="form-check-label" for="rememberMe" style="font-size:0.85rem;color:#555;">Remember Me</label>
            </div>
            <button type="submit" class="btn-submit">Log in</button>
            <div style="text-align:center;margin-top:10px;">
                <a href="#" class="forgot-link" onclick="toggleForgot(event)" style="display:inline;text-align:center;">Forgot Your Password?</a>
            </div>
        </form>

        <!-- Forgot password (client-side hint panel) -->
        <div id="forgot-panel">
            <p><i class="bi bi-info-circle me-1"></i> Please contact your system administrator to reset your password, or create a new passenger account using the <strong>New Passenger</strong> tab.</p>
            <button class="btn-submit" style="background:#1a3c5e; font-size:0.82rem; padding:9px;" onclick="showTab('register')">
                <i class="bi bi-person-plus me-1"></i>Create Passenger Account
            </button>
        </div>
    </div>

        <div style="text-align:center; margin-top:16px; font-size:0.85rem; color:#888;">
            Don't have an account? <a href="#" onclick="showTab('register'); return false;" style="color:#000; font-weight:700;">Register</a>
        </div>
    </div>

    <!-- ── Register Form ── -->
    <div class="form-section" id="section-register">
        <form method="post" action="${pageContext.request.contextPath}/users/register" id="reg-form">
            <!-- Role Picker -->
            <div class="mb-4">
                <label class="form-label">I am registering as a…</label>
                <div class="role-select">
                    <div class="role-opt selected" id="role-passenger" onclick="selectRole('PASSENGER')">
                        <i class="bi bi-person-fill"></i>
                        Passenger
                    </div>
                    <div class="role-opt" id="role-driver" onclick="selectRole('DRIVER')">
                        <i class="bi bi-bus-front-fill"></i>
                        Driver
                    </div>
                </div>
                <input type="hidden" name="registerRole" id="registerRole" value="PASSENGER">
            </div>
            <div class="mb-3">
                <label class="form-label">Full Name</label>
                <input type="text" name="name" class="form-control" required placeholder="Jane Doe" minlength="2" maxlength="100">
            </div>
            <div class="mb-3">
                <label class="form-label">Email address</label>
                <input type="email" name="email" class="form-control" required placeholder="you@example.com">
            </div>
            <!-- Driver-only field -->
            <div class="mb-3" id="license-field" style="display:none">
                <label class="form-label">Driver Licence / Registration Number</label>
                <input type="text" name="licenseNumber" id="licenseNumber" class="form-control" placeholder="e.g. DRV-00123" maxlength="50">
            </div>
            <div class="mb-3">
                <label class="form-label">Password</label>
                <input type="password" name="password" id="reg-password" class="form-control" required placeholder="At least 6 characters" minlength="6">
            </div>
            <div class="mb-3">
                <label class="form-label">Confirm Password</label>
                <input type="password" name="confirmPassword" id="confirmPassword" class="form-control" required placeholder="Repeat password">
                <div id="pw-match-msg" style="font-size:0.78rem; margin-top:4px;"></div>
            </div>
            <div class="alert-box" style="background:#fff8e1; border:1px solid #f9a825; color:#5d4037; border-radius:10px; padding:10px 14px; font-size:0.82rem; margin-bottom:14px;">
                <i class="bi bi-clock-history me-1"></i>
                <strong>Pending Approval:</strong> Your account will be reviewed by an administrator before you can sign in.
            </div>
            <button type="submit" class="btn-submit" id="reg-submit-btn">
                <i class="bi bi-send-fill me-2"></i>Submit Registration Request
            </button>
        </form>
        <div style="text-align:center; margin-top:14px; font-size:0.8rem; color:#888;">
            Already have an account? <a href="#" onclick="showTab('login'); return false;" style="color:#000; font-weight:700;">Sign in</a>
        </div>
    </div>
</div>

<script>
function showTab(tab) {
    document.querySelectorAll('.tab-btn').forEach((b, i) => {
        b.classList.toggle('active', (i === 0 && tab === 'login') || (i === 1 && tab === 'register'));
    });
    document.getElementById('section-login').classList.toggle('active', tab === 'login');
    document.getElementById('section-register').classList.toggle('active', tab === 'register');
    document.getElementById('forgot-panel').classList.remove('show');
}

function toggleForgot(e) {
    e.preventDefault();
    document.getElementById('forgot-panel').classList.toggle('show');
}

function selectRole(role) {
    document.getElementById('registerRole').value = role;
    document.getElementById('role-passenger').classList.toggle('selected', role === 'PASSENGER');
    document.getElementById('role-driver').classList.toggle('selected', role === 'DRIVER');
    const licField = document.getElementById('license-field');
    const licInput = document.getElementById('licenseNumber');
    if (role === 'DRIVER') {
        licField.style.display = 'block';
        licInput.required = true;
    } else {
        licField.style.display = 'none';
        licInput.required = false;
        licInput.value = '';
    }
}

// Password match validation
const cp = document.getElementById('confirmPassword');
const msg = document.getElementById('pw-match-msg');
const regBtn = document.getElementById('reg-submit-btn');
cp.addEventListener('input', function() {
    const pw = document.getElementById('reg-password').value;
    if (!this.value) { msg.textContent = ''; return; }
    if (this.value === pw) {
        msg.style.color = '#1a7a3a'; msg.textContent = '✓ Passwords match';
        regBtn.disabled = false;
    } else {
        msg.style.color = '#c0392b'; msg.textContent = '✗ Passwords do not match';
        regBtn.disabled = true;
    }
});

// If there's an error/success for register, open register tab
<% if ("register".equals(request.getAttribute("tab"))) { %>
showTab('register');
<% } %>
</script>
</body>
</html>
