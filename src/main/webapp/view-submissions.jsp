
<%@ page import="java.sql.*" %>
<%@ page import="com.codeaura.db.DBConnection" %>

<%
    if (session.getAttribute("adminLoggedIn") == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    int total = 0;
    int correct = 0;
    int incorrect = 0;
%>

<!DOCTYPE html>
<html>
<head>
    <title>CodeAura - View Submissions</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 25px;
            font-family: Arial, sans-serif;
            background: #f4f6fb;
        }

        .container {
            max-width: 1200px;
            margin: auto;
        }

        h1 {
            color: #252b48;
        }

        .summary {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            margin: 25px 0;
        }

        .card {
            flex: 1;
            min-width: 180px;
            padding: 22px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 3px 12px #00000012;
        }

        .card h3 {
            margin: 0 0 12px;
            color: #666;
        }

        .card p {
            margin: 0;
            font-size: 28px;
            font-weight: bold;
            color: #292e50;
        }

        .table-container {
            overflow-x: auto;
            background: white;
            padding: 20px;
            border-radius: 12px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 850px;
        }

        th, td {
            padding: 14px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }

        th {
            background: #292e50;
            color: white;
        }

        .correct {
            color: #168344;
            font-weight: bold;
        }

        .incorrect {
            color: #dc3545;
            font-weight: bold;
        }

        .back {
            display: inline-block;
            margin-bottom: 15px;
            padding: 10px 18px;
            color: white;
            background: #292e50;
            text-decoration: none;
            border-radius: 7px;
        }

        .empty {
            text-align: center;
            padding: 25px;
            color: #777;
        }
    </style>
</head>

<body>

<div class="container">

    <a href="admin-dashboard.jsp" class="back">
        Back to Dashboard
    </a>

    <h1>Student Submissions</h1>
    <p>View all student mission submissions and their results.</p>

    <%
        try {
            con = DBConnection.getConnection();

            String countSql =
                "SELECT COUNT(*) AS total, " +
                "SUM(CASE WHEN is_correct = 1 THEN 1 ELSE 0 END) AS correct_count, " +
                "SUM(CASE WHEN is_correct = 0 THEN 1 ELSE 0 END) AS incorrect_count " +
                "FROM mission_submissions";

            ps = con.prepareStatement(countSql);
            rs = ps.executeQuery();

            if (rs.next()) {
                total = rs.getInt("total");
                correct = rs.getInt("correct_count");
                incorrect = rs.getInt("incorrect_count");
            }

            rs.close();
            ps.close();
    %>

    <div class="summary">

        <div class="card">
            <h3>Total Submissions</h3>
            <p><%= total %></p>
        </div>

        <div class="card">
            <h3>Correct Answers</h3>
            <p><%= correct %></p>
        </div>

        <div class="card">
            <h3>Incorrect Answers</h3>
            <p><%= incorrect %></p>
        </div>

    </div>

    <div class="table-container">

        <table>

            <tr>
                <th>Submission ID</th>
                <th>Student</th>
                <th>Mission</th>
                <th>Submitted Answer</th>
                <th>Result</th>
                <th>Completed At</th>
            </tr>

            <%
                String sql =
                    "SELECT ms.id, u.username, m.title, " +
                    "ms.answer, ms.is_correct, ms.completed_at " +
                    "FROM mission_submissions ms " +
                    "LEFT JOIN users u ON ms.user_id = u.id " +
                    "LEFT JOIN missions m ON ms.mission_id = m.id " +
                    "ORDER BY ms.completed_at DESC";

                ps = con.prepareStatement(sql);
                rs = ps.executeQuery();

                boolean found = false;

                while (rs.next()) {
                    found = true;
                    boolean isCorrect = rs.getBoolean("is_correct");
            %>

            <tr>
                <td><%= rs.getInt("id") %></td>

                <td>
                    <%= rs.getString("username") == null
                        ? "Unknown Student"
                        : rs.getString("username") %>
                </td>

                <td>
                    <%= rs.getString("title") == null
                        ? "Unknown Mission"
                        : rs.getString("title") %>
                </td>

                <td><%= rs.getString("answer") %></td>

                <td>
                    <% if (isCorrect) { %>
                        <span class="correct">Correct</span>
                    <% } else { %>
                        <span class="incorrect">Incorrect</span>
                    <% } %>
                </td>

                <td><%= rs.getTimestamp("completed_at") %></td>
            </tr>

            <%
                }

                if (!found) {
            %>

            <tr>
                <td colspan="6" class="empty">
                    No submissions found.
                </td>
            </tr>

            <%
                }

            } catch (Exception e) {
                out.println("<tr><td colspan='6'>Unable to load submissions.</td></tr>");
                application.log("Submission loading error", e);
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception e) {}
                try { if (ps != null) ps.close(); } catch (Exception e) {}
                try { if (con != null) con.close(); } catch (Exception e) {}
            }
            %>

        </table>

    </div>

</div>

</body>
</html>
