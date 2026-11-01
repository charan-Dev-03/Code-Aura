
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.codeaura.db.DBConnection" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    Integer userId = (Integer) session.getAttribute("userId");

    if (!Boolean.TRUE.equals(session.getAttribute("userLoggedIn"))
            || userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = "";
    String email = "";
    String createdAt = "Not available";
    String accountStatus = "ACTIVE";

    int totalXP = 0;
    int playerLevel = 1;
    int totalSubmissions = 0;
    int correctAnswers = 0;
    int incorrectAnswers = 0;
    int completedMissions = 0;

    boolean studentFound = false;
    String errorMessage = null;

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>My Profile | CodeAura</title>

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #0b1020;
            color: #f8fafc;
        }

        nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            padding: 20px 6%;
            background: #11182b;
            border-bottom: 1px solid #29334d;
        }

        .logo {
            color: #a78bfa;
            font-size: 27px;
            font-weight: bold;
        }

        nav a {
            color: #cbd5e1;
            text-decoration: none;
            margin-left: 18px;
        }

        nav a:hover {
            color: #a78bfa;
        }

        .container {
            width: 90%;
            max-width: 1100px;
            margin: 40px auto;
        }

        .heading {
            margin-bottom: 30px;
        }

        .heading h1 {
            font-size: 34px;
            color: #c4b5fd;
        }

        .heading p {
            color: #94a3b8;
        }

        .profile-card {
            display: flex;
            align-items: center;
            gap: 25px;
            flex-wrap: wrap;
            padding: 30px;
            background: #151e34;
            border: 1px solid #303c59;
            border-radius: 18px;
            margin-bottom: 30px;
        }

        .avatar {
            width: 95px;
            height: 95px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            background: linear-gradient(135deg, #8b5cf6, #6d28d9);
            font-size: 42px;
        }

        .profile-info h2 {
            margin: 0 0 10px;
            font-size: 27px;
            color: #c4b5fd;
        }

        .profile-info p {
            margin: 8px 0;
            color: #cbd5e1;
        }

        .status {
            display: inline-block;
            padding: 7px 13px;
            background: #123d2a;
            color: #86efac;
            border-radius: 20px;
            font-size: 13px;
            font-weight: bold;
        }

        .section-title {
            margin: 35px 0 20px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 20px;
        }

        .stat-card {
            padding: 25px;
            background: #151e34;
            border: 1px solid #303c59;
            border-radius: 15px;
        }

        .stat-card .icon {
            font-size: 30px;
            margin-bottom: 12px;
        }

        .stat-card h3 {
            margin: 0 0 10px;
            color: #94a3b8;
            font-size: 15px;
        }

        .stat-card .value {
            font-size: 29px;
            font-weight: bold;
            color: #c4b5fd;
        }

        .xp-value {
            color: #facc15 !important;
        }

        .performance {
            padding: 25px;
            margin-top: 25px;
            background: #151e34;
            border: 1px solid #303c59;
            border-radius: 15px;
        }

        .performance-row {
            display: flex;
            justify-content: space-between;
            gap: 15px;
            padding: 17px 0;
            border-bottom: 1px solid #303c59;
        }

        .performance-row:last-child {
            border-bottom: none;
        }

        .performance-row span:last-child {
            font-weight: bold;
            color: #c4b5fd;
        }

        .correct {
            color: #86efac !important;
        }

        .incorrect {
            color: #fca5a5 !important;
        }

        .actions {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-top: 30px;
        }

        .action-btn {
            display: inline-block;
            padding: 13px 22px;
            background: linear-gradient(90deg, #8b5cf6, #6d28d9);
            color: white;
            text-decoration: none;
            border-radius: 9px;
            font-weight: bold;
        }

        .action-btn.secondary {
            background: #29334f;
        }

        .error {
            padding: 20px;
            background: #451b25;
            color: #fca5a5;
            border-radius: 10px;
        }

        .empty {
            text-align: center;
            padding: 30px;
            color: #94a3b8;
        }

        @media(max-width: 750px) {

            .stats-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

        }

        @media(max-width: 500px) {

            .stats-grid {
                grid-template-columns: 1fr;
            }

            .heading h1 {
                font-size: 27px;
            }

            .container {
                width: 94%;
            }

        }

    </style>

</head>

<body>

    <!-- NAVIGATION -->

    <nav>

        <div class="logo">&lt;/&gt; CodeAura</div>

        <div>
            <a href="dashboard.jsp">Dashboard</a>
            <a href="missions.jsp">Missions</a>
            <a href="leaderboard.jsp">Leaderboard</a>
            <a href="LogoutServlet">Logout</a>
        </div>

    </nav>


    <main class="container">

        <section class="heading">

            <h1>👤 My Student Profile</h1>

            <p>
                View your account details and programming learning progress.
            </p>

        </section>


        <%
            try {

                con = DBConnection.getConnection();

                if (con == null) {
                    throw new Exception("Database connection unavailable.");
                }

                // GET STUDENT DETAILS

                String studentSql =
                    "SELECT username, email, total_xp, player_level, " +
                    "created_at, account_status " +
                    "FROM users WHERE id = ?";

                ps = con.prepareStatement(studentSql);
                ps.setInt(1, userId);

                rs = ps.executeQuery();

                if (rs.next()) {

                    studentFound = true;

                    username = rs.getString("username");
                    email = rs.getString("email");
                    totalXP = rs.getInt("total_xp");
                    playerLevel = rs.getInt("player_level");
                    accountStatus = rs.getString("account_status");

                    if (rs.getTimestamp("created_at") != null) {
                        createdAt = rs.getTimestamp("created_at").toString();
                    }
                }

                rs.close();
                ps.close();

                if (!studentFound) {
                    throw new Exception("Student account not found.");
                }

                // GET SUBMISSION STATISTICS

                String statsSql =
                    "SELECT COUNT(*) AS total_submissions, " +
                    "COALESCE(SUM(CASE WHEN is_correct = 1 THEN 1 ELSE 0 END), 0) AS correct_answers, " +
                    "COALESCE(SUM(CASE WHEN is_correct = 0 THEN 1 ELSE 0 END), 0) AS incorrect_answers, " +
                    "COUNT(DISTINCT CASE WHEN is_correct = 1 THEN mission_id END) AS completed_missions " +
                    "FROM mission_submissions WHERE user_id = ?";

                ps = con.prepareStatement(statsSql);
                ps.setInt(1, userId);

                rs = ps.executeQuery();

                if (rs.next()) {

                    totalSubmissions = rs.getInt("total_submissions");
                    correctAnswers = rs.getInt("correct_answers");
                    incorrectAnswers = rs.getInt("incorrect_answers");
                    completedMissions = rs.getInt("completed_missions");

                }

                rs.close();
                ps.close();

            } catch (Exception e) {

                application.log("Student profile loading error", e);
                errorMessage = "Unable to load your profile. Please try again later.";

            } finally {

                try {
                    if (rs != null) rs.close();
                } catch (Exception e) {}

                try {
                    if (ps != null) ps.close();
                } catch (Exception e) {}

                try {
                    if (con != null) con.close();
                } catch (Exception e) {}

            }
        %>


        <% if (errorMessage != null) { %>

            <div class="error">
                <%= escapeHtml(errorMessage) %>
            </div>

        <% } else { %>


        <!-- STUDENT PROFILE -->

        <section class="profile-card">

            <div class="avatar">👨‍🎓</div>

            <div class="profile-info">

                <h2><%= escapeHtml(username) %></h2>

                <p>
                    📧 <%= escapeHtml(email) %>
                </p>

                <p>
                    🎓 Student ID: <%= userId %>
                </p>

                <p>
                    📅 Registered: <%= escapeHtml(createdAt) %>
                </p>

                <span class="status">
                    <%= escapeHtml(accountStatus) %>
                </span>

            </div>

        </section>


        <!-- STUDENT STATISTICS -->

        <h2 class="section-title">📊 Learning Overview</h2>

        <section class="stats-grid">


            <div class="stat-card">

                <div class="icon">⭐</div>

                <h3>Total Experience Points</h3>

                <div class="value xp-value">
                    <%= totalXP %> XP
                </div>

            </div>


            <div class="stat-card">

                <div class="icon">🏆</div>

                <h3>Current Player Level</h3>

                <div class="value">
                    Level <%= playerLevel %>
                </div>

            </div>


            <div class="stat-card">

                <div class="icon">🚀</div>

                <h3>Completed Missions</h3>

                <div class="value">
                    <%= completedMissions %>
                </div>

            </div>


            <div class="stat-card">

                <div class="icon">📝</div>

                <h3>Total Submissions</h3>

                <div class="value">
                    <%= totalSubmissions %>
                </div>

            </div>


            <div class="stat-card">

                <div class="icon">✅</div>

                <h3>Correct Answers</h3>

                <div class="value correct">
                    <%= correctAnswers %>
                </div>

            </div>


            <div class="stat-card">

                <div class="icon">❌</div>

                <h3>Incorrect Answers</h3>

                <div class="value incorrect">
                    <%= incorrectAnswers %>
                </div>

            </div>


        </section>


        <!-- PERFORMANCE -->

        <h2 class="section-title">📈 My Performance</h2>

        <section class="performance">

            <div class="performance-row">
                <span>Total XP Earned</span>
                <span class="xp-value"><%= totalXP %> XP</span>
            </div>

            <div class="performance-row">
                <span>Current Level</span>
                <span>Level <%= playerLevel %></span>
            </div>

            <div class="performance-row">
                <span>Successfully Completed Missions</span>
                <span class="correct"><%= completedMissions %></span>
            </div>

            <div class="performance-row">
                <span>Correct Submissions</span>
                <span class="correct"><%= correctAnswers %></span>
            </div>

            <div class="performance-row">
                <span>Incorrect Submissions</span>
                <span class="incorrect"><%= incorrectAnswers %></span>
            </div>

        </section>


        <!-- QUICK ACTIONS -->

        <div class="actions">

            <a href="missions.jsp" class="action-btn">
                🚀 Continue Learning
            </a>

            <a href="leaderboard.jsp" class="action-btn secondary">
                🏆 View Leaderboard
            </a>

            <a href="dashboard.jsp" class="action-btn secondary">
                Back to Dashboard
            </a>

        </div>


        <% } %>

    </main>

</body>
</html>
