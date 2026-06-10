<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>400 – Bad Request</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f8f9fa; }
        .error-code { font-size: 6rem; font-weight: 700; color: #6c757d; line-height: 1; }
    </style>
</head>
<body class="d-flex align-items-center justify-content-center" style="min-height:100vh">
<div class="text-center p-4">
    <div class="error-code">400</div>
    <h2 class="mt-3 mb-2">Bad Request</h2>
    <p class="text-muted mb-4">The request could not be understood by the server. Please check your input and try again.</p>
    <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary me-2">Go to Dashboard</a>
    <a href="javascript:history.back()" class="btn btn-outline-secondary">Go Back</a>
</div>
</body>
</html>
