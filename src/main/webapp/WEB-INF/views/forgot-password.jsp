<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SmartBus – Forgot Password</title>
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
        h2 { font-size: 1.8rem; font-weight: 900; color: #000; margin-bottom: 10px; }
        .subtitle { font-size: .88rem; color: #888; margin-bottom: 28px; line-height: 1.6; }
        .form-control {
            border-radius: 10px; border: 1.5px solid #e0e0e0;
            padding: 13px 16px; font-size: .9rem; width: 100%;
            outline: none; transition: border-color .2s; text-align: left;
        }
        .form-control:focus { border-color: #000; box-shadow: 0 0 0 3px rgba(0,0,0,.08); }
        .btn-submit {
            background: #000; color: #fff; border: none; border-radius: 12px;
            width: 100%; padding: 14px; font-size: .95rem; font-weight: 800;
            cursor: pointer; margin-top: 12px; transition: background .2s;
        }
        .btn-submit:hover { background: #00c853; color: #000; }
        .alert-box { border-radius: 10px; padding: 10px 14px; font-size: .82rem; margin-bottom: 16px; text-align: left; }
        .alert-error { background: #fff2f2; color: #c0392b; border: 1px solid #f5c6cb; }
        .already-link {
            display: inline-block; margin-top: 18px;
            font-size: .85rem; color: #555; text-decoration: none; font-weight: 600;
        }
        .already-link:hover { color: #000; }
        .back-link {
            display: block; margin-top: 10px;
            font-size: .8rem; color: #aaa; text-decoration: none;
        }
        .back-link:hover { color: #000; }
    </style>
</head>
<body>
<div class="auth-card">
    <div class="icon"><i class="bi bi-lock-fill" style="color:#000"></i></div>
    <h2>Forgot password?</h2>
    <p class="subtitle">
        No worries, we will send you instructions on how to<br>
        reset your password by email.
    </p>

    <% String forgotError = (String) request.getAttribute("forgotError"); %>
    <% if (forgotError != null) { %>
    <div class="alert-box alert-error">
        <i class="bi bi-exclamation-triangle-fill me-2"></i><%= forgotError %>
    </div>
    <% } %>

    <form method="post" action="${pageContext.request.contextPath}/forgot-password">
        <input type="email" name="email" class="form-control"
               placeholder="Email..."
               value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>"
               required autofocus>
        <button type="submit" class="btn-submit">Reset Password</button>
    </form>

    <a href="${pageContext.request.contextPath}/verify-code" class="already-link">
        I already have a code &rarr;
    </a>
    <a href="${pageContext.request.contextPath}/users/login" class="back-link">
        <i class="bi bi-arrow-left me-1"></i>Back to login
    </a>
</div>
</body>
</html>
