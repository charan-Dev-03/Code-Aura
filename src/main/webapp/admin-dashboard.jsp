
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.codeaura.db.DBConnection" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    // ADMIN SESSION SECURITY

    if (!Boolean.TRUE.equals(session.getAttribute("adminLoggedIn"))) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    String adminName = (String) session.getAttribute("adminUsername");

    if (adminName == null || adminName.trim().isEmpty()) {
        adminName = "Administrator";
    }

    String safeAdminName = escapeHtml(adminName);

    // DASHBOARD STATISTICS

    int totalStudents = 0;
    int totalMissions = 0;
    int totalSubmissions = 0;

    String dbError = null;

    try (Connection con = DBConnection.getConnection()) {

        if (con == null) {
            throw new Exception("Database connection is unavailable.");
        }

        // TOTAL STUDENTS

        String studentSql = "SELECT COUNT(*) FROM users";

        try (PreparedStatement ps = con.prepareStatement(studentSql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                totalStudents = rs.getInt(1);
            }
        }

        // TOTAL MISSIONS

        String missionSql = "SELECT COUNT(*) FROM missions";

        try (PreparedStatement ps = con.prepareStatement(missionSql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                totalMissions = rs.getInt(1);
            }
        }

        // TOTAL SUBMISSIONS

        String submissionSql = "SELECT COUNT(*) FROM mission_submissions";

        try (PreparedStatement ps = con.prepareStatement(submissionSql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                totalSubmissions = rs.getInt(1);
            }
        }

    } catch (Exception e) {

        application.log("Admin dashboard database error", e);

        dbError = "Unable to load dashboard statistics. Please check the database connection.";
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Admin Dashboard | CodeAura</title>

    <link rel="stylesheet" href="css/style.css">

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background:
                radial-gradient(circle at 10% 10%, #30205c, transparent 35%),
                #0b1020;
            color: #f8fafc;
        }

        /* NAVIGATION */

        .navbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 15px;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 22px;
            flex-wrap: wrap;
        }

        .nav-links a {
            text-decoration: none;
        }

        /* MAIN DASHBOARD */

        .admin-dashboard {
            padding: 45px 0;
        }

        /* WELCOME */

        .admin-welcome {
            margin-bottom: 35px;
        }

        .admin-welcome h1 {
            font-size: 32px;
            margin-bottom: 10px;
        }

        .admin-welcome p {
            color: #94a3b8;
        }

        .gradient-text {
            color: #a78bfa;
        }

        /* ADMIN PROFILE */

        .admin-profile {
            background: #151c31;
            border: 1px solid rgba(167, 139, 250, 0.2);
            border-radius: 16px;
            padding: 22px;
            margin-bottom: 35px;
        }

        .admin-profile h3 {
            margin-top: 0;
        }

        .admin-profile p {
            color: #cbd5e1;
            margin-bottom: 10px;
        }

        .admin-profile span {
            color: #a78bfa;
            font-weight: bold;
        }

        /* ERROR MESSAGE */

        .admin-error {
            color: #ffaaaa;
            background: rgba(255, 0, 0, 0.08);
            border: 1px solid rgba(255, 100, 100, 0.3);
            border-radius: 10px;
            padding: 14px;
            margin-bottom: 25px;
        }

        /* SECTIONS */

        .admin-section {
            margin-bottom: 40px;
        }

        .admin-section h2 {
            margin-bottom: 22px;
        }

        /* STATISTICS */

        .admin-stats {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 22px;
            margin-bottom: 40px;
        }

        .admin-stat {
            background: #151c31;
            border: 1px solid rgba(167, 139, 250, 0.25);
            padding: 28px;
            border-radius: 18px;
            transition: 0.3s ease;
        }

        .admin-stat:hover {
            transform: translateY(-5px);
            border-color: #a78bfa;
        }

        .admin-stat .icon {
            font-size: 32px;
            margin-bottom: 15px;
        }

        .admin-stat h2 {
            font-size: 34px;
            color: #a78bfa;
            margin: 0;
        }

        .admin-stat p {
            color: #94a3b8;
            margin-top: 8px;
        }

        /* MANAGEMENT CARDS */

        .admin-tools {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 22px;
        }

        .admin-tool {
            display: block;
            background: #151c31;
            padding: 28px;
            border: 1px solid rgba(167, 139, 250, 0.2);
            border-radius: 18px;
            color: #f8fafc;
            text-decoration: none;
            transition: 0.3s ease;
        }

        .admin-tool:hover {
            transform: translateY(-7px);
            border-color: #a78bfa;
            background: #1c2540;
            box-shadow: 0 10px 30px rgba(139, 92, 246, 0.15);
        }

        .admin-tool:focus-visible {
            outline: 3px solid #a78bfa;
            outline-offset: 4px;
        }

        .admin-tool .icon {
            font-size: 35px;
            margin-bottom: 15px;
        }

        .admin-tool h3 {
            margin-bottom: 10px;
            color: #ffffff;
        }

        .admin-tool p {
            color: #94a3b8;
            font-size: 14px;
            line-height: 1.7;
        }

        .admin-tool .open-link {
            color: #a78bfa;
            margin-top: 15px;
            font-weight: bold;
        }

        /* FOOTER */

        .footer {
            text-align: center;
            padding: 30px 15px;
        }

        /* RESPONSIVE DESIGN */

        @media screen and (max-width: 900px) {

            .admin-stats,
            .admin-tools {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

        }

        @media screen and (max-width: 600px) {

            .admin-dashboard {
                padding: 25px 15px;
            }

            .admin-stats,
            .admin-tools {
                grid-template-columns: 1fr;
            }

            .admin-welcome h1 {
                font-size: 26px;
            }

            .nav-links {
                gap: 12px;
            }

        }

    </style>

</head>

<body>

    <!-- NAVIGATION -->

    <nav class="navbar">

        <a href="admin-dashboard.jsp" class="logo">
            &lt;/&gt; CodeAura
        </a>

        <div class="nav-links">

            <a href="admin-dashboard.jsp">Dashboard</a>

            <a href="index.html">Website</a>

            <a href="AdminLogoutServlet">Logout</a>

        </div>

    </nav>


    <!-- MAIN DASHBOARD -->

    <main class="container admin-dashboard">

        <!-- WELCOME SECTION -->

        <section class="admin-welcome">

            <span class="badge">ADMIN CONTROL PANEL</span>

            <h1>
                Welcome,
                <span class="gradient-text"><%= safeAdminName %></span>!
            </h1>

            <p>
                Manage your CodeAura programming learning platform.
            </p>

        </section>


        <!-- ADMIN PROFILE -->

        <section class="admin-profile">

            <h3>🛡️ Administrator Profile</h3>

            <p>
                Logged in as:
                <span><%= safeAdminName %></span>
            </p>

            <p>Account Type: Administrator</p>

            <p>Access Level: Full Administration</p>

        </section>


        <!-- DATABASE ERROR -->

        <% if (dbError != null) { %>

            <div class="admin-error">
                <%= escapeHtml(dbError) %>
            </div>

        <% } %>


        <!-- STATISTICS -->

        <section class="admin-section">

            <h2>📊 Platform Overview</h2>

            <div class="admin-stats">

                <div class="admin-stat">

                    <div class="icon">👨‍🎓</div>

                    <h2><%= totalStudents %></h2>

                    <p>Total Registered Students</p>

                </div>


                <div class="admin-stat">

                    <div class="icon">💻</div>

                    <h2><%= totalMissions %></h2>

                    <p>Total Coding Missions</p>

                </div>


                <div class="admin-stat">

                    <div class="icon">📝</div>

                    <h2><%= totalSubmissions %></h2>

                    <p>Total Mission Submissions</p>

                </div>

            </div>

        </section>


        <!-- MANAGEMENT MODULES -->

        <section class="admin-section">

            <h2>⚙️ Management Modules</h2>

            <div class="admin-tools">

                <!-- STUDENT MANAGEMENT -->

                <a href="view-students.jsp" class="admin-tool">

                    <div class="icon">👨‍🎓</div>

                    <h3>Student Management</h3>

                    <p>
                        View registered students, manage their
                        accounts and monitor their learning progress.
                    </p>

                    <p class="open-link">
                        Open Student Management →
                    </p>

                </a>


                <!-- MISSION MANAGEMENT -->

                <a href="manage-missions.jsp" class="admin-tool">

                    <div class="icon">🚀</div>

                    <h3>Mission Management</h3>

                    <p>
                        Create, update, delete and manage
                        programming missions and questions.
                    </p>

                    <p class="open-link">
                        Open Mission Management →
                    </p>

                </a>


                <!-- SUBMISSION MANAGEMENT -->

                <a href="view-submissions.jsp" class="admin-tool">

                    <div class="icon">📋</div>

                    <h3>Submission Management</h3>

                    <p>
                        View student submissions, check answers
                        and monitor mission completion results.
                    </p>

                    <p class="open-link">
                        Open Submission Management →
                    </p>

                </a>


                <!-- NOTIFICATION MANAGEMENT - NEW -->

                <a href="admin-notifications.jsp" class="admin-tool">

                    <div class="icon">🔔</div>

                    <h3>Notification Management</h3>

                    <p>
                        Send announcements to all students or
                        individual students, view notification
                        history and delete old notifications.
                    </p>

                    <p class="open-link">
                        Open Notification Management →
                    </p>

                </a>
                
                
<!-- STUDENT ANALYTICS - NEW -->

<a href="student-analytics.jsp" class="admin-tool">

    <div class="icon">📊</div>

    <h3>Student Analytics</h3>

    <p>
        Monitor student performance, XP progression,
        mission completion, submission statistics
        and top-performing students.
    </p>

    <p class="open-link">
        Open Student Analytics →
    </p>

</a>
                

            </div>

        </section>

    </main>


    <!-- FOOTER -->

    <footer class="footer">

        <h2 class="logo">CodeAura</h2>

        <p>Think. Code. Conquer.</p>

        <p>© 2026 CodeAura Administration Panel.</p>

    </footer>

</body>

</html>
