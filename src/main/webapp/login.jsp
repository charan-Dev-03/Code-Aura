
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Login | CodeAura</title>

<link rel="stylesheet" href="css/style.css">

<style>
body {
    background:
    radial-gradient(circle at 15% 15%, #30205c, transparent 40%),
    radial-gradient(circle at 85% 85%, #12385b, transparent 40%),
    #0b1020;
}

.login-wrapper {
    min-height: calc(100vh - 75px);
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 40px 15px;
}

.login-card {
    width: 100%;
    max-width: 450px;
    padding: 40px;
    background: #151c31;
    border: 1px solid rgba(167,139,250,.3);
    border-radius: 22px;
    box-shadow: 0 20px 60px rgba(0,0,0,.35);
}

.login-heading {
    text-align: center;
    margin-bottom: 30px;
}

.login-heading h1 {
    font-size: 30px;
    margin-bottom: 8px;
}

.login-heading p {
    color: #94a3b8;
}

.login-icon {
    font-size: 42px;
    margin-bottom: 12px;
}

.login-card .btn {
    width: 100%;
    margin-top: 10px;
}

.login-footer {
    text-align: center;
    margin-top: 25px;
    color: #94a3b8;
    font-size: 14px;
}

.login-footer a {
    color: #a78bfa;
    font-weight: 700;
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
        <a href="register.jsp">Register</a>
    </div>

</nav>

<div class="login-wrapper">

    <div class="login-card">

        <div class="login-heading">

            <div class="login-icon">🔐</div>

            <h1>Welcome Back!</h1>

            <p>Continue your coding journey with CodeAura.</p>

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

        <form action="LoginServlet" method="post">

            <div class="form-group">

                <label>Username or Email</label>

                <input
                    type="text"
                    name="loginInput"
                    class="form-control"
                    placeholder="Enter username or email"
                    required>

            </div>

            <div class="form-group">

                <label>Password</label>

                <input
                    type="password"
                    name="password"
                    class="form-control"
                    placeholder="Enter your password"
                    required>

            </div>

            <button type="submit" class="btn btn-primary">
                Login to CodeAura →
            </button>

        </form>

        <div class="login-footer">

            Don't have an account?

            <a href="register.jsp">Create Account</a>

        </div>

    </div>

</div>

<footer class="footer">
    CodeAura | Think. Code. Conquer.
</footer>

</body>
</html>
