<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>CommuteSafe – Verify Code</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        * { box-sizing: border-box; }
        body {
            min-height: 100vh; margin: 0;
            background: linear-gradient(135deg, #000 0%, #0d1b2a 60%, #1a3c5e 100%);
            display: flex; align-items: center; justify-content: center;
            font-family: 'Segoe UI', sans-serif;
            padding: 20px 12px;
        }
        .auth-card {
            background: #fff; border-radius: 20px; padding: 40px 32px;
            width: 100%; max-width: 440px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.4);
            text-align: center;
        }
        .icon { font-size: 3rem; margin-bottom: 12px; }
        h2 { font-size: 1.6rem; font-weight: 900; color: #000; margin-bottom: 10px; }
        .subtitle { font-size: .88rem; color: #888; margin-bottom: 28px; line-height: 1.6; }
        .code-inputs { display: flex; gap: 10px; justify-content: center; margin-bottom: 20px; }
        .code-input {
            width: 54px; height: 64px; text-align: center;
            font-size: 1.7rem; font-weight: 700; color: #000;
            border: 2px solid #e0e0e0; border-radius: 12px;
            outline: none; transition: border-color .2s;
            caret-color: transparent;
        }
        .code-input:focus { border-color: #000; box-shadow: 0 0 0 3px rgba(0,0,0,.08); }
        .btn-submit {
            background: #000; color: #fff; border: none; border-radius: 12px;
            width: 100%; padding: 14px; font-size: .95rem; font-weight: 800;
            cursor: pointer; transition: background .2s;
        }
        .btn-submit:hover { background: #00c853; color: #000; }
        .alert-box { border-radius: 10px; padding: 10px 14px; font-size: .82rem; margin-bottom: 16px; text-align: left; }
        .alert-error { background: #fff2f2; color: #c0392b; border: 1px solid #f5c6cb; }
        .resend-link {
            display: block; margin-top: 14px;
            font-size: .85rem; color: #3b82f6; text-decoration: none;
        }
        .resend-link:hover { text-decoration: underline; }
        .back-link {
            display: block; margin-top: 8px;
            font-size: .8rem; color: #aaa; text-decoration: none;
        }
        .back-link:hover { color: #000; }
    </style>
</head>
<body>
<div class="auth-card">
    <div class="icon"><i class="bi bi-envelope-check-fill" style="color:#000"></i></div>
    <h2>Check your email</h2>
    <%
        String sentTo = (String) request.getAttribute("sentTo");
        if (sentTo == null) {
            jakarta.servlet.http.HttpSession sess = request.getSession(false);
            if (sess != null) sentTo = (String) sess.getAttribute("resetEmail");
        }
    %>
    <p class="subtitle">
        We sent a 5-digit code to<br>
        <strong><%= sentTo != null ? sentTo : "your email address" %></strong><br>
        <span style="color:#aaa;font-size:.8rem">Valid for 15 minutes. Check your spam folder too.</span>
    </p>

    <% String codeError = (String) request.getAttribute("codeError"); %>
    <% if (codeError != null) { %>
    <div class="alert-box alert-error">
        <i class="bi bi-exclamation-triangle-fill me-2"></i><%= codeError %>
    </div>
    <% } %>

    <form method="post" action="${pageContext.request.contextPath}/verify-code" id="verify-form">
        <div class="code-inputs">
            <input type="text" maxlength="1" class="code-input" name="d1" id="d1"
                   inputmode="numeric" pattern="[0-9]" required autocomplete="off">
            <input type="text" maxlength="1" class="code-input" name="d2" id="d2"
                   inputmode="numeric" pattern="[0-9]" required autocomplete="off">
            <input type="text" maxlength="1" class="code-input" name="d3" id="d3"
                   inputmode="numeric" pattern="[0-9]" required autocomplete="off">
            <input type="text" maxlength="1" class="code-input" name="d4" id="d4"
                   inputmode="numeric" pattern="[0-9]" required autocomplete="off">
            <input type="text" maxlength="1" class="code-input" name="d5" id="d5"
                   inputmode="numeric" pattern="[0-9]" required autocomplete="off">
        </div>
        <button type="submit" class="btn-submit">Verify Code</button>
    </form>

    <a href="${pageContext.request.contextPath}/forgot-password" class="resend-link">
        <i class="bi bi-arrow-clockwise me-1"></i>Didn't receive it? Resend code
    </a>
    <a href="${pageContext.request.contextPath}/users/login" class="back-link">
        <i class="bi bi-arrow-left me-1"></i>Back to login
    </a>
</div>

<script>
const inputs = document.querySelectorAll('.code-input');
inputs.forEach((inp, i) => {
    inp.addEventListener('input', () => {
        inp.value = inp.value.replace(/\D/g, '').slice(0, 1);
        if (inp.value && i < inputs.length - 1) inputs[i + 1].focus();
    });
    inp.addEventListener('keydown', e => {
        if (e.key === 'Backspace' && !inp.value && i > 0) inputs[i - 1].focus();
    });
    inp.addEventListener('paste', e => {
        e.preventDefault();
        const pasted = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g, '');
        [...pasted].slice(0, 5).forEach((ch, j) => { if (inputs[i + j]) inputs[i + j].value = ch; });
        const next = Math.min(i + pasted.length, inputs.length - 1);
        inputs[next].focus();
    });
});
inputs[0].focus();
</script>
</body>
</html>
