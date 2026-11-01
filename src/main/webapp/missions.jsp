
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.codeaura.db.DBConnection" %>

<%!
    private String safe(String value) {
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

    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String category = request.getParameter("category");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    String sql =
        "SELECT id, title, description, category, difficulty, " +
        "option_a, option_b, option_c, option_d, xp_reward " +
        "FROM missions";

    if (category != null &&
        (category.equals("Java") ||
         category.equals("SQL") ||
         category.equals("DSA"))) {

        sql += " WHERE category = ?";
    }

    sql += " ORDER BY id DESC";
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Programming Missions | CodeAura</title>

    <style>
    
    .result-message {
    padding: 18px;
    margin-bottom: 25px;
    border-radius: 10px;
    font-weight: bold;
    font-size: 17px;
}

.result-message.success {
    background: #123d2a;
    color: #86efac;
    border: 1px solid #22c55e;
}

.result-message.error {
    background: #451b25;
    color: #fca5a5;
    border: 1px solid #ef4444;
}

.result-message.info {
    background: #252b50;
    color: #c4b5fd;
    border: 1px solid #8b5cf6;
}
    
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
            padding: 20px 6%;
            background: #11182b;
            border-bottom: 1px solid #29334d;
        }

        .logo {
            font-size: 27px;
            font-weight: bold;
            color: #a78bfa;
        }

        nav a {
            color: #cbd5e1;
            text-decoration: none;
            margin-left: 20px;
        }

        .container {
            width: 90%;
            max-width: 1200px;
            margin: 40px auto;
        }

        .heading {
            margin-bottom: 25px;
        }

        .heading h1 {
            font-size: 34px;
            margin-bottom: 10px;
        }

        .heading p {
            color: #94a3b8;
        }

        .filters {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 30px;
        }

        .filters a {
            padding: 11px 20px;
            border-radius: 8px;
            background: #1a2340;
            color: white;
            text-decoration: none;
            border: 1px solid #34405f;
        }

        .filters a:hover {
            background: #7138d8;
        }

        .mission-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 22px;
        }

        .mission-card {
            padding: 25px;
            border-radius: 16px;
            background: #151e34;
            border: 1px solid #303c59;
        }

        .mission-card h2 {
            margin-top: 0;
            color: #c4b5fd;
        }

        .description {
            color: #cbd5e1;
            line-height: 1.7;
        }

        .details {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin: 18px 0;
        }

        .tag {
            padding: 7px 12px;
            border-radius: 20px;
            background: #29334d;
            color: #c4b5fd;
            font-size: 13px;
        }

        .xp {
            color: #facc15;
            font-weight: bold;
        }

        .question-label {
            display: block;
            padding: 12px;
            margin: 10px 0;
            background: #202b46;
            border-radius: 8px;
            cursor: pointer;
        }

        .question-label:hover {
            background: #303d60;
        }

        .question-label input {
            margin-right: 10px;
            accent-color: #8b5cf6;
        }

        .submit-btn {
            width: 100%;
            padding: 13px;
            margin-top: 15px;
            border: none;
            border-radius: 9px;
            background: linear-gradient(90deg, #8b5cf6, #6d28d9);
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
        }

        .submit-btn:hover {
            opacity: 0.9;
        }

        .empty {
            padding: 35px;
            background: #151e34;
            border-radius: 12px;
            text-align: center;
            color: #cbd5e1;
        }

        @media(max-width: 750px) {
            .mission-grid {
                grid-template-columns: 1fr;
            }

            .heading h1 {
                font-size: 27px;
            }
        }
    </style>
</head>

<body>

<nav>
    <div class="logo">&lt;/&gt; CodeAura</div>

    <div>
        <a href="dashboard.jsp">Dashboard</a>
        <a href="LogoutServlet">Logout</a>
    </div>
</nav>

<main class="container">

    <section class="heading">
        <h1>🚀 Programming Missions</h1>
        <p>Choose a mission, solve the question and earn XP!</p>
    </section>

    <div class="filters">
        <a href="missions.jsp">All Missions</a>
        <a href="missions.jsp?category=Java">Java</a>
        <a href="missions.jsp?category=SQL">SQL</a>
        <a href="missions.jsp?category=DSA">DSA</a>
    </div>

<%
    String result = request.getParameter("result");
    String xpMessage = request.getParameter("xp");
%>

<% if ("correct".equals(result)) { %>
    <div class="result-message success">
        🎉 Correct Answer! You earned <%= safe(xpMessage) %> XP!
    </div>
<% } else if ("already".equals(result)) { %>
    <div class="result-message info">
        ⭐ Correct answer! You have already earned XP for this mission.
    </div>
<% } else if ("incorrect".equals(result)) { %>
    <div class="result-message error">
        ❌ Incorrect Answer. Try another mission!
    </div>
<% } else if ("invalid".equals(result)) { %>
    <div class="result-message error">
        Please select a valid answer.
    </div>
<% } else if ("notfound".equals(result)) { %>
    <div class="result-message error">
        Mission not found.
    </div>
<% } else if ("error".equals(result)) { %>
    <div class="result-message error">
        Something went wrong. Please try again.
    </div>
<% } %>

    <div class="mission-grid">

        <%
            boolean found = false;

            try {
                con = DBConnection.getConnection();

                ps = con.prepareStatement(sql);

                if (category != null &&
                    (category.equals("Java") ||
                     category.equals("SQL") ||
                     category.equals("DSA"))) {

                    ps.setString(1, category);
                }

                rs = ps.executeQuery();

                while (rs.next()) {
                    found = true;

                    int missionId = rs.getInt("id");
                    String title = rs.getString("title");
                    String description = rs.getString("description");
                    String difficulty = rs.getString("difficulty");
                    String missionCategory = rs.getString("category");
                    int xp = rs.getInt("xp_reward");
        %>

        <article class="mission-card">

            <h2><%= safe(title) %></h2>

            <p class="description">
                <%= safe(description) %>
            </p>

            <div class="details">
                <span class="tag"><%= safe(missionCategory) %></span>
                <span class="tag"><%= safe(difficulty) %></span>
                <span class="xp">⭐ <%= xp %> XP</span>
            </div>

            <h3>Select your answer:</h3>

            <form action="SubmitMissionServlet" method="post">

                <input type="hidden"
                       name="missionId"
                       value="<%= missionId %>">

                <label class="question-label">
                    <input type="radio" name="answer"
                           value="A" required>
                    A. <%= safe(rs.getString("option_a")) %>
                </label>

                <label class="question-label">
                    <input type="radio" name="answer"
                           value="B">
                    B. <%= safe(rs.getString("option_b")) %>
                </label>

                <label class="question-label">
                    <input type="radio" name="answer"
                           value="C">
                    C. <%= safe(rs.getString("option_c")) %>
                </label>

                <label class="question-label">
                    <input type="radio" name="answer"
                           value="D">
                    D. <%= safe(rs.getString("option_d")) %>
                </label>

                <button type="submit" class="submit-btn">
                    Submit Answer
                </button>

            </form>

        </article>

        <%
                }

                if (!found) {
        %>

        <div class="empty">
            <h2>No Missions Available</h2>
            <p>New programming missions will appear here when the administrator adds them.</p>
        </div>

        <%
                }

            } catch (Exception e) {
                application.log("Error loading student missions", e);
        %>

        <div class="empty">
            Unable to load missions. Please try again later.
        </div>

        <%
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception e) {}
                try { if (ps != null) ps.close(); } catch (Exception e) {}
                try { if (con != null) con.close(); } catch (Exception e) {}
            }
        %>

    </div>

</main>

</body>
</html>
