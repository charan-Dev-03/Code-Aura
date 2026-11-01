
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.codeaura.db.DBConnection" %>

<%
    if (!Boolean.TRUE.equals(session.getAttribute("userLoggedIn"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");

    Integer totalXP = (Integer) session.getAttribute("totalXP");
    Integer playerLevel = (Integer) session.getAttribute("playerLevel");
    Integer userId = (Integer) session.getAttribute("userId");

    if (totalXP == null) totalXP = 0;
    if (playerLevel == null) playerLevel = 1;

    int unreadCount = 0;

    // GET UNREAD NOTIFICATION COUNT
    if (userId != null) {

        String sql =
            "SELECT COUNT(*) FROM notifications " +
            "WHERE user_id = ? AND is_read = FALSE";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    unreadCount = rs.getInt(1);
                }
            }

        } catch (Exception e) {
            application.log("Error loading unread notification count", e);
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Student Dashboard | CodeAura</title>

<link rel="stylesheet" href="css/style.css">

<style>

body {
    background:
    radial-gradient(circle at 10% 10%, #30205c, transparent 35%),
    #0b1020;
}

.dashboard {
    padding: 45px 0;
}

.welcome {
    margin-bottom: 35px;
}

.welcome h1 {
    font-size: 32px;
    margin-bottom: 8px;
}

.welcome p {
    color: #94a3b8;
}

.dashboard-stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 22px;
    margin-bottom: 40px;
}

.stat-card {
    background: #151c31;
    padding: 25px;
    border: 1px solid rgba(167,139,250,.2);
    border-radius: 16px;
}

.stat-card .icon {
    font-size: 25px;
    margin-bottom: 12px;
    color: #c4b5fd;
    font-weight: bold;
}

.stat-card h2 {
    font-size: 30px;
    color: #a78bfa;
}

.stat-card p {
    color: #94a3b8;
}

.dashboard-section {
    margin-bottom: 40px;
}

.dashboard-section h2 {
    margin-bottom: 20px;
}

.mission-card {
    background: #151c31;
    border: 1px solid rgba(167,139,250,.2);
    padding: 28px;
    border-radius: 16px;
}

.mission-card h3 {
    margin-bottom: 12px;
}

.mission-card p {
    color: #94a3b8;
    margin-bottom: 20px;
}

.dashboard-actions {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 20px;
}

.action-card {
    text-align: center;
    padding: 28px;
}

.action-card .icon {
    font-size: 28px;
    font-weight: bold;
    color: #c4b5fd;
    margin-bottom: 12px;
}

.action-card p {
    color: #94a3b8;
    font-size: 14px;
    margin: 10px 0 18px;
}

/* NOTIFICATION BADGE */

.notification-link {
    position: relative;
}

.notification-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 19px;
    height: 19px;
    padding: 0 5px;
    margin-left: 5px;
    background: #ef4444;
    color: white;
    border-radius: 20px;
    font-size: 11px;
    font-weight: bold;
    vertical-align: middle;
}

@media(max-width: 1000px) {
    .dashboard-actions {
        grid-template-columns: repeat(2, 1fr);
    }
}

@media(max-width: 700px) {

    .dashboard-stats,
    .dashboard-actions {
        grid-template-columns: 1fr;
    }

    .welcome h1 {
        font-size: 26px;
    }
}

</style>

</head>

<body>

<!-- NAVIGATION -->

<nav class="navbar">

    <a href="dashboard.jsp" class="logo">
        &lt;/&gt; CodeAura
    </a>

    <div class="nav-links">

        <a href="dashboard.jsp">Dashboard</a>

        <a href="missions.jsp">Missions</a>

        <a href="leaderboard.jsp">Leaderboard</a>

        <a href="learning-history.jsp">Learning History</a>

        <a href="achievements.jsp">Achievements</a>

        <a href="NotificationServlet" class="notification-link">
            Notifications

            <% if (unreadCount > 0) { %>
                <span class="notification-badge">
                    <%= unreadCount %>
                </span>
            <% } %>

        </a>

        <a href="LogoutServlet">Logout</a>

    </div>

</nav>


<main class="container dashboard">

    <!-- WELCOME -->

    <section class="welcome">

        <span class="badge">STUDENT DASHBOARD</span>

        <h1>
            Welcome back,
            <span class="gradient-text"><%= username %></span>!
        </h1>

        <p>
            Ready to continue your coding adventure?
            Complete missions and earn more XP.
        </p>

    </section>


    <!-- STATISTICS -->

    <section class="dashboard-stats">

        <div class="stat-card">

            <div class="icon">XP</div>

            <h2><%= totalXP %></h2>

            <p>Total Experience Points</p>

        </div>


        <div class="stat-card">

            <div class="icon">LEVEL</div>

            <h2><%= playerLevel %></h2>

            <p>Current Player Level</p>

        </div>


        <div class="stat-card">

            <div class="icon">STATUS</div>

            <h2>Ready</h2>

            <p>Coding Journey Status</p>

        </div>

    </section>


    <!-- MISSIONS -->

    <section class="dashboard-section">

        <h2>Start Your Coding Journey</h2>

        <div class="mission-card">

            <h3>Ready for your next challenge?</h3>

            <p>
                Explore programming questions, solve missions,
                improve your knowledge and earn XP rewards.
            </p>

            <a href="missions.jsp" class="btn btn-primary">
                Explore Missions
            </a>

        </div>

    </section>


    <!-- QUICK ACCESS -->

    <section class="dashboard-section">

        <h2>Quick Access</h2>

        <div class="dashboard-actions">


            <!-- MISSIONS -->

            <div class="card action-card">

                <div class="icon">CODE</div>

                <h3>Coding Missions</h3>

                <p>
                    Practice programming through challenges.
                </p>

                <a href="missions.jsp" class="btn btn-primary">
                    Start Learning
                </a>

            </div>


            <!-- LEADERBOARD -->

            <div class="card action-card">

                <div class="icon">RANK</div>

                <h3>Leaderboard</h3>

                <p>
                    Compare your XP with other students.
                </p>

                <a href="leaderboard.jsp" class="btn btn-secondary">
                    View Rankings
                </a>

            </div>


            <!-- PROFILE -->

            <div class="card action-card">

                <div class="icon">USER</div>

                <h3>My Profile</h3>

                <p>
                    View your student account information.
                </p>

                <a href="student-profile.jsp" class="btn btn-secondary">
                    My Profile
                </a>

            </div>


            <!-- ACHIEVEMENTS -->

            <div class="card action-card">

                <div class="icon">BADGE</div>

                <h3>My Achievements</h3>

                <p>
                    Unlock badges by earning XP and completing missions.
                </p>

                <a href="achievements.jsp" class="btn btn-secondary">
                    View Achievements
                </a>

            </div>


        </div>

    </section>

</main>


<footer class="footer">

    <h2 class="logo">CodeAura</h2>

    <p>Think. Code. Conquer.</p>

    <p>© 2026 CodeAura. All Rights Reserved.</p>

</footer>

</body>
</html>
