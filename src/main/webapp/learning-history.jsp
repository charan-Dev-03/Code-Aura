
<%@ page import="java.sql.*" %>
<%@ page import="com.codeaura.db.DBConnection" %>

<%
    if (!Boolean.TRUE.equals(session.getAttribute("userLoggedIn"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Learning History - CodeAura</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        body {
            background: #100d20;
            color: white;
            padding: 30px;
        }

        .container {
            max-width: 1200px;
            margin: auto;
        }

        h1 {
            color: #c5a3ff;
            margin-bottom: 10px;
        }

        .subtitle {
            color: #aaa;
            margin-bottom: 25px;
        }

        .history-box {
            background: #1d1930;
            border: 1px solid #393052;
            border-radius: 12px;
            padding: 20px;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 850px;
        }

        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #393052;
        }

        th {
            color: #c5a3ff;
            background: #29223f;
        }

        td {
            color: #ddd;
        }

        .correct {
            color: #4ade80;
            font-weight: bold;
        }

        .incorrect {
            color: #fb7185;
            font-weight: bold;
        }

        .xp {
            color: #facc15;
            font-weight: bold;
        }

        .empty {
            text-align: center;
            padding: 30px;
            color: #aaa;
        }

        .back-btn {
            display: inline-block;
            margin-top: 25px;
            padding: 12px 22px;
            background: #8b5cf6;
            color: white;
            text-decoration: none;
            border-radius: 7px;
        }

        .back-btn:hover {
            background: #7c3aed;
        }
    </style>
</head>

<body>

<div class="container">

    <h1>My Learning History</h1>

    <p class="subtitle">
        Track your mission attempts, answers and XP progress.
    </p>

    <div class="history-box">

        <table>

            <tr>
                <th>Mission</th>
                <th>Category</th>
                <th>Difficulty</th>
                <th>Your Answer</th>
                <th>Result</th>
                <th>XP Earned</th>
                <th>Completed At</th>
            </tr>

            <%
                Connection con = null;
                PreparedStatement ps = null;
                ResultSet rs = null;

                boolean found = false;

                try {
                    con = DBConnection.getConnection();

                    String sql =
                        "SELECT ms.id, ms.answer, ms.is_correct, " +
                        "ms.completed_at, m.title, m.category, " +
                        "m.difficulty, " +
                        "CASE WHEN ms.is_correct = 1 AND ms.id = (" +
                        "SELECT MIN(ms2.id) FROM mission_submissions ms2 " +
                        "WHERE ms2.user_id = ms.user_id " +
                        "AND ms2.mission_id = ms.mission_id " +
                        "AND ms2.is_correct = 1) " +
                        "THEN m.xp_reward ELSE 0 END AS earned_xp " +
                        "FROM mission_submissions ms " +
                        "JOIN missions m ON ms.mission_id = m.id " +
                        "WHERE ms.user_id = ? " +
                        "ORDER BY ms.completed_at DESC, ms.id DESC";

                    ps = con.prepareStatement(sql);
                    ps.setInt(1, userId);

                    rs = ps.executeQuery();

                    while (rs.next()) {
                        found = true;

                        boolean isCorrect = rs.getBoolean("is_correct");
                        int earnedXP = rs.getInt("earned_xp");
            %>

            <tr>
                <td><%= rs.getString("title") %></td>

                <td><%= rs.getString("category") %></td>

                <td><%= rs.getString("difficulty") %></td>

                <td><%= rs.getString("answer") %></td>

                <td>
                    <% if (isCorrect) { %>
                        <span class="correct">Correct</span>
                    <% } else { %>
                        <span class="incorrect">Incorrect</span>
                    <% } %>
                </td>

                <td class="xp">
                    <%= earnedXP %> XP
                </td>

                <td>
                    <%= rs.getTimestamp("completed_at") %>
                </td>
            </tr>

            <%
                    }

                    if (!found) {
            %>

            <tr>
                <td colspan="7" class="empty">
                    No learning history found. Start completing missions!
                </td>
            </tr>

            <%
                    }

                } catch (Exception e) {
                    application.log("Learning history error", e);
            %>

            <tr>
                <td colspan="7" class="empty">
                    Unable to load learning history. Please try again.
                </td>
            </tr>

            <%
                } finally {
                    try { if (rs != null) rs.close(); } catch (Exception e) {}
                    try { if (ps != null) ps.close(); } catch (Exception e) {}
                    try { if (con != null) con.close(); } catch (Exception e) {}
                }
            %>

        </table>

    </div>

    <a href="dashboard.jsp" class="back-btn">
        Back to Dashboard
    </a>

</div>

</body>
</html>
