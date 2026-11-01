
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

    String dbError = null;
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Manage Missions | CodeAura</title>

<link rel="stylesheet" href="css/style.css">

<style>

body {
    background: #0b1020;
    color: #f8fafc;
    font-family: Arial, sans-serif;
}

.container {
    max-width: 1450px;
    margin: 50px auto;
    padding: 20px;
}

.header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    flex-wrap: wrap;
    margin-bottom: 30px;
}

h1 {
    color: #a78bfa;
}

.add-btn {
    background: linear-gradient(90deg,#8b5cf6,#6d28d9);
    color: white;
    padding: 13px 22px;
    border-radius: 9px;
    text-decoration: none;
    font-weight: bold;
}

.table-card {
    background: #151c31;
    border: 1px solid #343b60;
    border-radius: 15px;
    padding: 20px;
    overflow-x: auto;
}

table {
    width: 100%;
    border-collapse: collapse;
    min-width: 1000px;
}

th, td {
    padding: 15px;
    text-align: left;
    border-bottom: 1px solid #343b60;
}

th {
    color: #a78bfa;
    background: #10172b;
}

td {
    color: #cbd5e1;
}

tr:hover {
    background: #202a45;
}

.empty {
    text-align: center;
    padding: 30px;
    color: #94a3b8;
}

.error {
    color: #fca5a5;
    background: #451f2a;
    padding: 14px;
    border-radius: 9px;
    margin-bottom: 20px;
}

.success {
    background: #123d30;
    color: #4ade80;
    padding: 14px;
    border-radius: 9px;
    margin-bottom: 20px;
}

.back-btn {
    display: inline-block;
    color: #a78bfa;
    text-decoration: none;
    margin-bottom: 20px;
}

.action-btn {
    display: inline-block;
    padding: 9px 16px;
    background: linear-gradient(90deg,#8b5cf6,#6d28d9);
    color: white;
    text-decoration: none;
    border-radius: 7px;
    font-weight: bold;
    font-size: 13px;
    transition: 0.3s;
}

.action-btn:hover {
    background: #7c3aed;
    transform: translateY(-2px);
}

.delete-btn {
    display: inline-block;
    padding: 9px 16px;
    margin-left: 6px;
    background: linear-gradient(90deg,#ef4444,#b91c1c);
    color: white;
    border: none;
    border-radius: 7px;
    font-weight: bold;
    font-size: 13px;
    cursor: pointer;
    transition: 0.3s;
}

.delete-btn:hover {
    background: #dc2626;
    transform: translateY(-2px);
}

@media(max-width:600px) {
    .container {
        padding: 12px;
    }
}

</style>

</head>

<body>

<div class="container">

    <a href="admin-dashboard.jsp" class="back-btn">
        ← Back to Dashboard
    </a>

    <div class="header">

        <div>
            <h1>🚀 Mission Management</h1>
            <p>View and manage all programming missions.</p>
        </div>

        <a href="add-question.jsp" class="add-btn">
            + Add New Mission
        </a>

    </div>

    <!-- SUCCESS MESSAGES -->

    <% if ("1".equals(request.getParameter("updated"))) { %>

        <div class="success">
            Mission updated successfully!
        </div>

    <% } %>

    <% if ("1".equals(request.getParameter("deleted"))) { %>

        <div class="success">
            Mission deleted successfully!
        </div>

    <% } %>

    <!-- ERROR MESSAGES -->

    <% if ("submissions".equals(request.getParameter("error"))) { %>

        <div class="error">
            Cannot delete this mission because student submissions
            are linked to it. Manage those submissions first.
        </div>

    <% } else if (request.getParameter("error") != null) { %>

        <div class="error">
            Unable to complete the requested operation.
            Please check the details and try again.
        </div>

    <% } %>

    <div class="table-card">

        <table>

            <thead>

                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>Category</th>
                    <th>Difficulty</th>
                    <th>XP Reward</th>
                    <th>Created By</th>
                    <th>Actions</th>
                </tr>

            </thead>

            <tbody>

            <%
                boolean hasMissions = false;

                try (Connection con = DBConnection.getConnection();

                     PreparedStatement ps = con.prepareStatement(
                         "SELECT id, title, category, difficulty, xp_reward, created_by " +
                         "FROM missions ORDER BY id DESC"
                     );

                     ResultSet rs = ps.executeQuery()) {

                    while (rs.next()) {

                        hasMissions = true;

                        int missionId = rs.getInt("id");
            %>

                <tr>

                    <td><%= missionId %></td>

                    <td><%= escapeHTML(rs.getString("title")) %></td>

                    <td><%= escapeHTML(rs.getString("category")) %></td>

                    <td><%= escapeHTML(rs.getString("difficulty")) %></td>

                    <td><%= rs.getInt("xp_reward") %> XP</td>

                    <td><%= rs.getInt("created_by") %></td>

                    <td style="white-space:nowrap;">

                        <!-- EDIT BUTTON -->

                        <a href="<%= request.getContextPath() %>/EditMissionServlet?id=<%= missionId %>"
                           class="action-btn">
                            ✏️ Edit
                        </a>

                        <!-- DELETE BUTTON -->

                        <form action="<%= request.getContextPath() %>/DeleteMissionServlet"
                              method="post"
                              style="display:inline;"
                              onsubmit="return confirm('Are you sure you want to delete this mission? This action cannot be undone.');">

                            <input type="hidden"
                                   name="id"
                                   value="<%= missionId %>">

                            <button type="submit" class="delete-btn">
                                🗑️ Delete
                            </button>

                        </form>

                    </td>

                </tr>

            <%
                    }

                } catch (Exception e) {

                    application.log("Error loading missions", e);

                    dbError = "Unable to load missions. Check database connection.";
                }

                if (dbError != null) {
            %>

                <tr>
                    <td colspan="7" class="empty error">
                        <%= dbError %>
                    </td>
                </tr>

            <%
                } else if (!hasMissions) {
            %>

                <tr>
                    <td colspan="7" class="empty">
                        No missions found. Create your first mission!
                    </td>
                </tr>

            <%
                }
            %>

            </tbody>

        </table>

    </div>

</div>

</body>

</html>
