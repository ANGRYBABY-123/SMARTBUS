<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>SmartBus - Sign In</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{min-height:100vh;background:linear-gradient(145deg,#050c1a 0%,#0d1f38 55%,#0a3d2b 100%);display:flex;align-items:center;justify-content:center;font-family:Segoe UI,system-ui,sans-serif;padding:20px 16px}
.card{background:#fff;border-radius:24px;width:100%;max-width:420px;box-shadow:0 32px 80px rgba(0,0,0,.5);overflow:hidden}
.card-hdr{background:linear-gradient(135deg,#0a0f1e,#0d2137);padding:26px 28px 20px;text-align:center}
.brand-icon{font-size:2rem;color:#00e676}.brand-name{font-size:1.7rem;font-weight:900;color:#fff;letter-spacing:-.5px;margin-top:6px}.brand-name span{color:#00e676}.brand-tag{font-size:.77rem;color:#64748b;margin-top:4px}
.tabs{display:flex;border-bottom:1px solid #f0f0f0;background:#fafafa}
.tab-btn{flex:1;padding:12px 8px;font-size:.87rem;font-weight:700;border:none;background:transparent;color:#94a3b8;cursor:pointer;border-bottom:3px solid transparent;transition:all .2s}
.tab-btn.active{color:#0d1f38;border-bottom-color:#00c853;background:#fff}
.card-body{padding:26px}
.form-section{display:none}.form-section.active{display:block}
.alert{border-radius:10px;padding:11px 14px;font-size:.82rem;margin-bottom:18px;display:flex;align-items:flex-start;gap:8px}
.alert-error{background:#fff2f2;color:#c0392b;border:1px solid #fcc}
.alert-success{background:#f0fff4;color:#15803d;border:1px solid #bbf7d0}
.btn-google{display:flex;align-items:center;justify-content:center;gap:10px;width:100%;padding:12px;border:1.5px solid #e5e7eb;border-radius:12px;background:#fff;color:#374151;font-size:.9rem;font-weight:600;text-decoration:none;transition:border-color .2s,box-shadow .2s;margin-bottom:18px}
.btn-google:hover{border-color:#4285F4;box-shadow:0 2px 8px rgba(66,133,244,.15);color:#374151}
.divider{display:flex;align-items:center;gap:10px;margin-bottom:18px}
.divider hr{flex:1;border:none;border-top:1px solid #e5e7eb}
.divider span{font-size:.75rem;color:#9ca3af}
.field{margin-bottom:14px}
.field label{display:block;font-size:.78rem;font-weight:700;color:#374151;margin-bottom:5px;text-transform:uppercase;letter-spacing:.04em}
.field input{width:100%;padding:11px 14px;border:1.5px solid #e5e7eb;border-radius:10px;font-size:.9rem;color:#111;outline:none;transition:border-color .2s,box-shadow .2s}
.field input:focus{border-color:#00c853;box-shadow:0 0 0 3px rgba(0,200,83,.12)}
.field input::placeholder{color:#9ca3af}
.remember{display:flex;align-items:center;gap:8px;font-size:.83rem;color:#6b7280;margin-bottom:6px;cursor:pointer}
.remember input{accent-color:#000;width:15px;height:15px}
.btn-main{width:100%;padding:13px;background:#000;color:#fff;border:none;border-radius:12px;font-size:.95rem;font-weight:800;cursor:pointer;transition:background .2s;margin-top:6px}
.btn-main:hover{background:#00c853;color:#000}
.btn-main:disabled{background:#d1d5db;color:#9ca3af;cursor:not-allowed}
.link-row{text-align:center;margin-top:14px;font-size:.8rem;color:#9ca3af}
.link-row a{color:#0d1f38;font-weight:700;text-decoration:none}
.link-row a:hover{text-decoration:underline}
.forgot{font-size:.8rem;color:#9ca3af;text-decoration:none;display:block;text-align:center;margin-top:10px}
.forgot:hover{color:#374151}
.forgot-panel{display:none;margin-top:14px;background:#f8fafc;border-radius:12px;padding:14px;font-size:.82rem;color:#555;border:1px solid #e5e7eb}
.forgot-panel.show{display:block}
.role-toggle{display:flex;border:1.5px solid #e5e7eb;border-radius:10px;overflow:hidden;margin-bottom:16px}
.role-btn{flex:1;padding:11px 8px;border:none;font-size:.84rem;font-weight:700;cursor:pointer;transition:all .18s}
.role-btn.on{background:#0d1f38;color:#fff}
.role-btn.off{background:#fff;color:#9ca3af;border-left:1.5px solid #e5e7eb}
.pending-notice{display:flex;align-items:flex-start;gap:8px;background:#fffbeb;border:1px solid #fcd34d;border-radius:10px;padding:10px 12px;font-size:.8rem;color:#78350f;margin-bottom:14px}
.pending-notice i{margin-top:1px;flex-shrink:0;color:#d97706}
.pw-msg{font-size:.76rem;margin-top:4px;min-height:16px}
</style></head><body>
<div class="card">
  <div class="card-hdr">
    <div class="brand-icon"><i class="bi bi-bus-front-fill"></i></div>
    <div class="brand-name">Smart<span>Bus</span></div>
    <div class="brand-tag">Real-time bus tracking &amp; AI assistant</div>
  </div>
  <div class="tabs">
    <button class="tab-btn active" id="tab-login" onclick="showTab('login')"><i class="bi bi-box-arrow-in-right"></i> Sign In</button>
    <button class="tab-btn" id="tab-register" onclick="showTab('register')"><i class="bi bi-person-plus"></i> Register</button>
  </div>
  <div class="card-body">
    <% if (request.getAttribute("error") != null) { %>
    <div class="alert alert-error"><i class="bi bi-exclamation-triangle-fill"></i><span><%= request.getAttribute("error") %></span></div>
    <% } %>
    <% if (request.getAttribute("success") != null) { %>
    <div class="alert alert-success"><i class="bi bi-check-circle-fill"></i><span><%= request.getAttribute("success") %></span></div>
    <% } %>
    <!-- SIGN IN -->
    <div class="form-section active" id="section-login">
      <a href="${pageContext.request.contextPath}/oauth/google/init" class="btn-google">
        <svg width="18" height="18" viewBox="0 0 48 48"><path fill="#4285F4" d="M45.12 24.5c0-1.56-.14-3.06-.4-4.5H24v8.51h11.84c-.51 2.75-2.06 5.08-4.39 6.64v5.52h7.11c4.16-3.83 6.56-9.47 6.56-16.17z"/><path fill="#34A853" d="M24 46c5.94 0 10.92-1.97 14.56-5.33l-7.11-5.52c-1.97 1.32-4.49 2.1-7.45 2.1-5.73 0-10.58-3.87-12.31-9.07H4.34v5.7C7.96 41.07 15.4 46 24 46z"/><path fill="#FBBC05" d="M11.69 28.18C11.25 26.86 11 25.45 11 24s.25-2.86.69-4.18v-5.7H4.34C2.85 17.09 2 20.45 2 24c0 3.55.85 6.91 2.34 9.88l7.35-5.7z"/><path fill="#EA4335" d="M24 10.75c3.23 0 6.13 1.11 8.41 3.29l6.31-6.31C34.91 4.18 29.93 2 24 2 15.4 2 7.96 6.93 4.34 14.12l7.35 5.7c1.73-5.2 6.58-9.07 12.31-9.07z"/></svg>
        Continue with Google
      </a>
      <div class="divider"><hr><span>or sign in with email</span><hr></div>
      <form method="post" action="${pageContext.request.contextPath}/users/login">
        <div class="field"><label>Email</label><input type="email" name="email" required autofocus placeholder="you@example.com"></div>
        <div class="field"><label>Password</label><input type="password" name="password" required placeholder="&bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;"></div>
        <label class="remember"><input type="checkbox" name="rememberMe" value="true"> Remember me for 30 days</label>
        <button type="submit" class="btn-main">Sign In</button>
        <a href="#" class="forgot" onclick="toggleForgot(event)">Forgot password?</a>
      </form>
      <div class="forgot-panel" id="forgot-panel">
        <p style="margin-bottom:10px"><i class="bi bi-info-circle"></i> Contact your admin to reset your password, or register a new account.</p>
        <button class="btn-main" style="font-size:.82rem" onclick="showTab('register')"><i class="bi bi-person-plus"></i> Create New Account</button>
      </div>
      <div class="link-row">Don&apos;t have an account? <a href="#" onclick="showTab('register');return false;">Register</a></div>
    </div>
    <!-- REGISTER -->
    <div class="form-section" id="section-register">
      <form method="post" action="${pageContext.request.contextPath}/users/register" id="reg-form">
        <div class="role-toggle">
          <button type="button" class="role-btn on" id="role-passenger" onclick="selectRole('PASSENGER')"><i class="bi bi-person-fill"></i> Passenger</button>
          <button type="button" class="role-btn off" id="role-driver" onclick="selectRole('DRIVER')"><i class="bi bi-bus-front-fill"></i> Driver</button>
        </div>
        <input type="hidden" name="registerRole" id="registerRole" value="PASSENGER">
        <div class="field"><label>Full Name</label><input type="text" name="name" required placeholder="Jane Doe" minlength="2" maxlength="100"></div>
        <div class="field"><label>Email</label><input type="email" name="email" required placeholder="you@example.com"></div>
        <div class="field" id="license-field" style="display:none"><label>Licence / Registration No.</label><input type="text" name="licenseNumber" id="licenseNumber" placeholder="e.g. DRV-00123" maxlength="50"></div>
        <div class="field"><label>Password</label><input type="password" name="password" id="reg-password" required placeholder="At least 6 characters" minlength="6"></div>
        <div class="field"><label>Confirm Password</label><input type="password" name="confirmPassword" id="confirmPassword" required placeholder="Repeat password"><div class="pw-msg" id="pw-match-msg"></div></div>
        <div class="pending-notice"><i class="bi bi-clock-history"></i><span>Your account will be reviewed by an admin before you can sign in.</span></div>
        <button type="submit" class="btn-main" id="reg-submit-btn">Create Account</button>
      </form>
      <div class="link-row">Already have an account? <a href="#" onclick="showTab('login');return false;">Sign in</a></div>
    </div>
  </div>
</div>
<script>
function showTab(tab){
  document.getElementById('tab-login').classList.toggle('active',tab==='login');
  document.getElementById('tab-register').classList.toggle('active',tab==='register');
  document.getElementById('section-login').classList.toggle('active',tab==='login');
  document.getElementById('section-register').classList.toggle('active',tab==='register');
  if(tab==='login')document.getElementById('forgot-panel').classList.remove('show');
}
function toggleForgot(e){e.preventDefault();document.getElementById('forgot-panel').classList.toggle('show');}
function selectRole(role){
  document.getElementById('registerRole').value=role;
  document.getElementById('role-passenger').className='role-btn '+(role==='PASSENGER'?'on':'off');
  document.getElementById('role-driver').className='role-btn '+(role==='DRIVER'?'on':'off');
  const show=role==='DRIVER';
  const lf=document.getElementById('license-field');
  const li=document.getElementById('licenseNumber');
  lf.style.display=show?'block':'none';li.required=show;if(!show)li.value='';
}
document.getElementById('confirmPassword').addEventListener('input',function(){
  const pw=document.getElementById('reg-password').value;
  const msg=document.getElementById('pw-match-msg');
  const btn=document.getElementById('reg-submit-btn');
  if(!this.value){msg.textContent='';btn.disabled=false;return;}
  if(this.value===pw){msg.style.color='#15803d';msg.textContent='? Passwords match';btn.disabled=false;}
  else{msg.style.color='#c0392b';msg.textContent='? Passwords do not match';btn.disabled=true;}
});
<% if ("register".equals(request.getAttribute("tab"))) { %>showTab('register');<% } %>
</script></body></html>
