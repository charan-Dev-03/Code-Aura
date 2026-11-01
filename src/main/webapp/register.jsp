
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Join CodeAura | Registration</title>
    <link rel="stylesheet" href="css/style.css">

    <style>
        body {
            background:
                radial-gradient(circle at 15% 15%, #30205c, transparent 40%),
                radial-gradient(circle at 85% 85%, #12385b, transparent 40%),
                #0b1020;
        }

        .register-wrapper {
            min-height: calc(100vh - 75px);
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 45px 15px;
        }

        .register-card {
            width: 100%;
            max-width: 480px;
            background: rgba(21, 28, 49, 0.96);
            border: 1px solid rgba(167,139,250,.3);
            border-radius: 22px;
            padding: 38px;
            box-shadow: 0 20px 60px rgba(0,0,0,.35);
        }

        .register-heading {
            text-align: center;
            margin-bottom: 28px;
        }

        .register-heading h1 {
            font-size: 30px;
            margin-bottom: 8px;
        }

        .register-heading p {
            color: #94a3b8;
            font-size: 14px;
        }

        .register-logo {
            font-size: 38px;
            margin-bottom: 12px;
        }

        .register-card .btn {
            width: 100%;
            margin-top: 10px;
        }

        .register-footer {
            text-align: center;
            margin-top: 22px;
            color: #94a3b8;
            font-size: 14px;
        }

        .register-footer a {
            color: #a78bfa;
            font-weight: 700;
        }

        .password-note {
            font-size: 11px;
            color: #94a3b8;
            margin-top: 5px;
        }
    </style>
</head>

<body>

<nav class="navbar">
    <a href="index.html" class="logo">&lt;/&gt; CodeAura</a>

    <div class="nav-links">
        <a href="index.html">Home</a>
        <a href="login.jsp">Login</a>
    </div>
</nav>

<div class="register-wrapper">

    <div class="register-card">

        <div class="register-heading">

            <div class="register-logo">🚀</div>

            <h1>Create Your Account</h1>

            <p>
                Join CodeAura and start your coding adventure!
            </p>

        </div>

<%
    String successMessage =
        (String) request.getAttribute("successMessage");

    String errorMessage =
        (String) request.getAttribute("errorMessage");
%>

<% if (successMessage != null) { %>
    <div class="alert alert-success">
        <%= successMessage %>
        <br>
        <a href="login.jsp">Login to CodeAura →</a>
    </div>
<% } %>

<% if (errorMessage != null) { %>
    <div class="alert alert-error">
        <%= errorMessage %>
    </div>
<% } %>

        <form action="RegisterServlet" method="post">

            <div class="form-group">
                <label>Username</label>
                <input
                    type="text"
                    name="username"
                    class="form-control"
                    placeholder="Choose your username"
                    required
                    maxlength="50">
            </div>

            <div class="form-group">
                <label>Email Address</label>
                <input
                    type="email"
                    name="email"
                    class="form-control"
                    placeholder="Enter your email"
                    required
                    maxlength="100">
            </div>

            <div class="form-group">
                <label>Password</label>
                <input
                    type="password"
                    name="password"
                    class="form-control"
                    placeholder="Create a password"
                    required>
                <p class="password-note">
                    Use a strong password with at least 8 characters.
                </p>
            </div>

            <div class="form-group">
                <label>Confirm Password</label>
                <input
                    type="password"
                    name="confirmPassword"
                    class="form-control"
                    placeholder="Re-enter your password"
                    required>
            </div>

            <button type="submit" class="btn btn-primary">
                Create Account →
            </button>

        </form>

        <div class="register-footer">
            Already have an account?
            <a href="login.jsp">Login Here</a>
        </div>

    </div>

</div>

<footer class="footer">
    CodeAura | Think. Code. Conquer.
</footer>

</body>
</html>
