
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Admin Login | CodeAura</title>

<link rel="stylesheet" href="css/style.css">

<style>
body {
    background:
    radial-gradient(circle at 15% 15%, #30205c, transparent 40%),
    radial-gradient(circle at 85% 85%, #12385b, transparent 40%),
    #0b1020;
}

.admin-wrapper {
    min-height: calc(100vh - 75px);
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 40px 15px;
}

.admin-card {
    width: 100%;
    max-width: 450px;
    padding: 40px;
    background: #151c31;
    border: 1px solid rgba(167,139,250,.3);
    border-radius: 22px;
    box-shadow: 0 20px 60px rgba(0,0,0,.35);
}

.admin-heading {
    text-align: center;
    margin-bottom: 30px;
}

.admin-heading h1 {
    font-size: 30px;
    margin-bottom: 8px;
}

.admin-heading p {
    color: #94a3b8;
}

.admin-icon {
    font-size: 45px;
    margin-bottom: 12px;
}

.admin-card .btn {
    width: 100%;
    margin-top: 10px;
}

.admin-note {
    text-align: center;
    color: #94a3b8;
    font-size: 13px;
    margin-top: 22px;
}
</style>

</head>

<body>

<nav class="navbar">

    <a href="index.html" class="logo">
        &lt;/&gt; CodeAura
    </a>

    <div class="nav-links">
        <a href="index.html">Home</a>
        <a href="login.jsp">Student Login</a>
    </div>

</nav>

<div class="admin-wrapper">

    <div class="admin-card">

        <div class="admin-heading">

            <div class="admin-icon">🛡️</div>

            <h1>Administrator Login</h1>

            <p>
                Access your CodeAura administration panel.
            </p>

        </div>

        <%
            String errorMessage =
                (String) request.getAttribute("errorMessage");
        %>

        <% if (errorMessage != null) { %>

            <div class="alert alert-error">
                <%= errorMessage %>
            </div>

        <% } %>

        <form action="AdminLoginServlet" method="post">

            <div class="form-group">

                <label>Admin Username</label>

                <input
                    type="text"
                    name="username"
                    class="form-control"
                    placeholder="Enter admin username"
                    required>

            </div>

            <div class="form-group">

                <label>Admin Password</label>

                <input
                    type="password"
                    name="password"
                    class="form-control"
                    placeholder="Enter admin password"
                    required>

            </div>

            <button type="submit" class="btn btn-primary">
                Admin Login →
            </button>

        </form>

        <div class="admin-note">
            Restricted access: Authorized administrators only.
        </div>

    </div>

</div>

<footer class="footer">
    CodeAura | Administration Portal
</footer>

</body>
</html>
