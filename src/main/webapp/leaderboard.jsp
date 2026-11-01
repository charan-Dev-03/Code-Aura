
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

    int rank = 0;
    int currentStudentRank = 0;
    int totalStudents = 0;

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Leaderboard | CodeAura</title>

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
            margin-left: 20px;
        }

        nav a:hover {
            color: #a78bfa;
        }

        .container {
            width: 90%;
            max-width: 1100px;
            margin: 45px auto;
        }

        .heading {
            text-align: center;
            margin-bottom: 35px;
        }

        .heading h1 {
            font-size: 36px;
            color: #c4b5fd;
        }

        .heading p {
            color: #94a3b8;
        }

        .summary {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        .summary-card {
            background: #151e34;
            border: 1px solid #303c59;
            padding: 25px;
            border-radius: 15px;
            text-align: center;
        }

        .summary-card h2 {
            color: #a78bfa;
            font-size: 30px;
            margin: 10px 0;
        }

        .summary-card p {
            color: #94a3b8;
            margin: 0;
        }

        .leaderboard-box {
            background: #151e34;
            border: 1px solid #303c59;
            border-radius: 16px;
            padding: 20px;
            overflow-x: auto;
        }

        table {
            width: 100%;
            min-width: 650px;
            border-collapse: collapse;
        }

        th {
            background: #29334f;
            color: white;
            padding: 17px;
            text-align: left;
        }

        td {
            padding: 17px;
            border-bottom: 1px solid #303c59;
            color: #e2e8f0;
        }

        tr.current-student {
            background: #29234a;
        }

        .rank {
            font-weight: bold;
            color: #c4b5fd;
        }

        .gold {
            color: #facc15;
        }

        .silver {
            color: #cbd5e1;
        }

        .bronze {
            color: #d99a65;
        }

        .xp {
            color: #facc15;
            font-weight: bold;
        }

        .level {
            display: inline-block;
            padding: 7px 12px;
            border-radius: 20px;
            background: #30305a;
            color: #c4b5fd;
        }

        .you {
            color: #86efac;
            font-size: 12px;
            font-weight: bold;
        }

        .empty {
            text-align: center;
            padding: 30px;
            color: #94a3b8;
        }

        .back-btn {
            display: inline-block;
            padding: 12px 20px;
            margin-bottom: 25px;
            background: #29334f;
            color: white;
            text-decoration: none;
            border-radius: 8px;
        }

        .back-btn:hover {
            background: #7138d8;
        }

        @media(max-width: 600px) {

            .container {
                width: 94%;
                margin: 25px auto;
            }

            .heading h1 {
                font-size: 28px;
            }

            .summary {
                grid-template-columns: 1fr;
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
            <a href="LogoutServlet">Logout</a>
        </div>

    </nav>


    <main class="container">

        <a href="dashboard.jsp" class="back-btn">
            ← Back to Dashboard
        </a>


        <!-- HEADING -->

        <section class="heading">

            <h1>🏆 Student Leaderboard</h1>

            <p>
                Compete with other students and become the
                CodeAura champion!
            </p>

        </section>


        <%
            try {

                con = DBConnection.getConnection();

                if (con == null) {
                    throw new Exception("Database connection unavailable.");
                }

                String countSql = "SELECT COUNT(*) FROM users";

                try (PreparedStatement countPs =
                        con.prepareStatement(countSql);
                     ResultSet countRs = countPs.executeQuery()) {

                    if (countRs.next()) {
                        totalStudents = countRs.getInt(1);
                    }
                }

                String rankSql =
                    "SELECT COUNT(*) + 1 FROM users " +
                    "WHERE total_xp > " +
                    "(SELECT total_xp FROM users WHERE id = ?)";

                try (PreparedStatement rankPs =
                        con.prepareStatement(rankSql)) {

                    rankPs.setInt(1, userId);

                    try (ResultSet rankRs = rankPs.executeQuery()) {
                        if (rankRs.next()) {
                            currentStudentRank = rankRs.getInt(1);
                        }
                    }
                }

        %>


        <!-- SUMMARY -->

        <section class="summary">

            <div class="summary-card">

                <p>Total Registered Students</p>

                <h2><%= totalStudents %></h2>

            </div>

            <div class="summary-card">

                <p>Your Current Rank</p>

                <h2>
                    <%= currentStudentRank > 0
                        ? "#" + currentStudentRank
                        : "N/A" %>
                </h2>

            </div>

        </section>


        <!-- LEADERBOARD TABLE -->

        <section class="leaderboard-box">

            <table>

                <thead>

                    <tr>
                        <th>Rank</th>
                        <th>Student</th>
                        <th>Total XP</th>
                        <th>Level</th>
                    </tr>

                </thead>

                <tbody>

                    <%
                        String sql =
                            "SELECT id, username, total_xp, player_level " +
                            "FROM users " +
                            "ORDER BY total_xp DESC, player_level DESC, " +
                            "username ASC";

                        ps = con.prepareStatement(sql);
                        rs = ps.executeQuery();

                        while (rs.next()) {

                            rank++;

                            int studentId = rs.getInt("id");
                            String username = rs.getString("username");
                            int xp = rs.getInt("total_xp");
                            int level = rs.getInt("player_level");

                            boolean isCurrentStudent =
                                studentId == userId;

                            String rankClass = "";

                            if (rank == 1) {
                                rankClass = "gold";
                            } else if (rank == 2) {
                                rankClass = "silver";
                            } else if (rank == 3) {
                                rankClass = "bronze";
                            }
                    %>

                    <tr class="<%= isCurrentStudent
                        ? "current-student" : "" %>">

                        <td class="rank <%= rankClass %>">

                            <% if (rank == 1) { %>
                                🥇
                            <% } else if (rank == 2) { %>
                                🥈
                            <% } else if (rank == 3) { %>
                                🥉
                            <% } else { %>
                                #<%= rank %>
                            <% } %>

                        </td>

                        <td>

                            <%= escapeHtml(username) %>

                            <% if (isCurrentStudent) { %>
                                <span class="you"> (YOU)</span>
                            <% } %>

                        </td>

                        <td class="xp">
                            ⭐ <%= xp %> XP
                        </td>

                        <td>
                            <span class="level">
                                Level <%= level %>
                            </span>
                        </td>

                    </tr>

                    <%
                        }

                        if (rank == 0) {
                    %>

                    <tr>
                        <td colspan="4" class="empty">
                            No students registered yet.
                        </td>
                    </tr>

                    <%
                        }

                    %>

                </tbody>

            </table>

        </section>


        <%
            } catch (Exception e) {

                application.log("Leaderboard loading error", e);
        %>

            <div class="empty">
                Unable to load leaderboard.
                Please try again later.
            </div>

        <%
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

    </main>

</body>
</html>
