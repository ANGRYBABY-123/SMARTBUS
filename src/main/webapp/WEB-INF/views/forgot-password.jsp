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
            background: #f0f2f5;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Segoe UI', sans-serif;
            padding: 20px 12px;
        }
        .auth-card {
            background: #fff; border-radius: 20px; padding: 48px 40px;
            width: 100%; max-width: 520px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.08);
            text-align: center;
        }
        h1 { font-size: 2rem; font-weight: 900; color: #0d0d2b; margin-bottom: 10px; }
        .subtitle { font-size: .88rem; color: #bbb; margin-bottom: 28px; }
        .field-label { font-size: .85rem; font-weight: 600; color: #333; text-align: left; display: block; margin-bottom: 6px; }
        .form-control {
            border-radius: 12px; border: 1.5px solid #e0e0e0;
            padding: 13px 16px; font-size: .9rem; width: 100%;
            outline: none; transition: border-color .2s; text-align: left;
        }
        .form-control:focus { border-color: #2b3fdb; box-shadow: 0 0 0 3px rgba(43,63,219,.1); }
        .btn-action {
            background: #2b3fdb; color: #fff; border: none; border-radius: 40px;
            width: 100%; padding: 14px; font-size: .95rem; font-weight: 700;
            cursor: pointer; margin-top: 10px; transition: background .2s;
            display: block; text-align: center; text-decoration: none;
        }
        .btn-action:hover { background: #1a2fb0; color: #fff; }
        .alert-box { border-radius: 10px; padding: 10px 14px; font-size: .82rem; margin-bottom: 16px; text-align: left; }
        .alert-error { background: #fff2f2; color: #c0392b; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>
<div class="auth-card">
    <h1>Reset Your Password.</h1>
    <p class="subtitle">Please provide the following details.</p>

    <% String forgotError = (String) request.getAttribute("forgotError"); %>
    <% if (forgotError != null) { %>
    <div class="alert-box alert-error">
        <i class="bi bi-exclamation-triangle-fill me-2"></i><%= forgotError %>
    </div>
    <% } %>

    <form method="post" action="${pageContext.request.contextPath}/forgot-password" style="text-align:left;">
        <label class="field-label">Email Address</label>
        <input type="email" name="email" class="form-control"
               placeholder="john@example.com"
               value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>"
               required autofocus>
        <button type="submit" class="btn-action">Send verification code</button>
    </form>

    <a href="${pageContext.request.contextPath}/verify-code" class="btn-action" style="margin-top:8px;">Continue</a>
    <a href="${pageContext.request.contextPath}/users/login" class="btn-action" style="margin-top:8px;">Cancel</a>
</div>
</body>
</html>
