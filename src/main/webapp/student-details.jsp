
<%@ page import="java.sql.*" %>
<%@ page import="com.codeaura.db.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%!
    private String escapeHTML(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    if (!Boolean.TRUE.equals(session.getAttribute("adminLoggedIn"))) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    String studentIdParam = request.getParameter("id");
    String dbError = null;

    int studentId = 0;
    boolean studentFound = false;

    String username = "";
    String email = "";
    int totalXP = 0;
    int playerLevel = 0;
    Timestamp registeredDate = null;

    try {
        studentId = Integer.parseInt(studentIdParam);

        if (studentId <= 0) {
            dbError = "Invalid student ID.";
        }

    } catch (Exception e) {
        dbError = "Invalid student ID.";
    }

    if (dbError == null) {

        try (Connection con = DBConnection.getConnection();

             PreparedStatement ps = con.prepareStatement(
                 "SELECT id, username, email, total_xp, " +
                 "player_level, created_at FROM users WHERE id = ?"
             )) {

            ps.setInt(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    studentFound = true;

                    username = rs.getString("username");
                    email = rs.getString("email");
                    totalXP = rs.getInt("total_xp");
                    playerLevel = rs.getInt("player_level");
                    registeredDate = rs.getTimestamp("created_at");
                }
            }

        } catch (Exception e) {

            application.log("Error loading student details", e);

            dbError = "Unable to load student details. Check database connection.";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Student Details | CodeAura</title>

<link rel="stylesheet" href="css/style.css">

<style>

body {
    background: #0b1020;
    color: #f8fafc;
    font-family: Arial, sans-serif;
}

.container {
    max-width: 900px;
    margin: 50px auto;
    padding: 20px;
}

.back-btn {
    display: inline-block;
    color: #a78bfa;
    text-decoration: none;
    margin-bottom: 25px;
}

h1 {
    color: #a78bfa;
}

.subtitle {
    color: #cbd5e1;
    margin-bottom: 30px;
}

.details-card {
    background: #151c31;
    border: 1px solid #343b60;
    border-radius: 15px;
    padding: 30px;
}

.detail-row {
    display: flex;
    justify-content: space-between;
    gap: 20px;
    padding: 18px 5px;
    border-bottom: 1px solid #343b60;
}

.detail-row:last-child {
    border-bottom: none;
}

.detail-label {
    color: #a78bfa;
    font-weight: bold;
}

.detail-value {
    color: #f8fafc;
    text-align: right;
    overflow-wrap: anywhere;
}

.level-badge {
    display: inline-block;
    background: #312e81;
    color: #c4b5fd;
    padding: 7px 14px;
    border-radius: 20px;
    font-weight: bold;
}

.xp-value {
    color: #4ade80;
    font-weight: bold;
}

.error {
    background: #451f2a;
    color: #fca5a5;
    padding: 15px;
    border-radius: 9px;
    margin-bottom: 20px;
}

@media(max-width:600px) {

    .container {
        padding: 12px;
    }

    .details-card {
        padding: 15px;
    }

    .detail-row {
        flex-direction: column;
        gap: 8px;
    }

    .detail-value {
        text-align: left;
    }

}

</style>

</head>

<body>

<div class="container">

    <a href="view-students.jsp" class="back-btn">
        ← Back to Students
    </a>

    <h1>👨‍🎓 Student Details</h1>

    <p class="subtitle">
        View complete information about the selected student.
    </p>

    <% if (dbError != null) { %>

        <div class="error">
            <%= escapeHTML(dbError) %>
        </div>

    <% } else if (!studentFound) { %>

        <div class="error">
            Student record not found.
        </div>

    <% } else { %>

        <div class="details-card">

            <div class="detail-row">
                <span class="detail-label">Student ID</span>
                <span class="detail-value"><%= studentId %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Username</span>
                <span class="detail-value"><%= escapeHTML(username) %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Email Address</span>
                <span class="detail-value"><%= escapeHTML(email) %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Total XP</span>
                <span class="detail-value xp-value">
                    <%= totalXP %> XP
                </span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Player Level</span>
                <span class="detail-value">
                    <span class="level-badge">
                        Level <%= playerLevel %>
                    </span>
                </span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Registration Date</span>
                <span class="detail-value">
                    <%= registeredDate != null ? registeredDate : "Not available" %>
                </span>
            </div>

        </div>

    <% } %>

</div>

</body>
</html>
