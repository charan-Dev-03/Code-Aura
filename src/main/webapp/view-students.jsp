
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
    int studentCount = 0;

    String search = request.getParameter("search");

    if (search == null) {
        search = "";
    }

    search = search.trim();

    int levelFilter = 0;

    try {
        levelFilter = Integer.parseInt(request.getParameter("level"));

        if (levelFilter < 0) {
            levelFilter = 0;
        }

    } catch (Exception e) {
        levelFilter = 0;
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>View Students | CodeAura</title>

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

.back-btn {
    display: inline-block;
    color: #a78bfa;
    text-decoration: none;
    margin-bottom: 20px;
}

h1 {
    color: #a78bfa;
}

.subtitle {
    color: #cbd5e1;
    margin-bottom: 25px;
}

.stats-card {
    background: #151c31;
    border: 1px solid #343b60;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 25px;
}

.stats-card h3 {
    color: #a78bfa;
    margin-top: 0;
}

.stats-card p {
    font-size: 28px;
    font-weight: bold;
    margin-bottom: 0;
}

/* SEARCH FORM */

.search-form {
    display: flex;
    gap: 10px;
    margin-bottom: 25px;
    flex-wrap: wrap;
}

.search-form input {
    flex: 1;
    min-width: 220px;
    padding: 13px;
    border: 1px solid #343b60;
    border-radius: 8px;
    background: #10172b;
    color: white;
    font-size: 15px;
}

.search-form input:focus {
    outline: none;
    border-color: #8b5cf6;
}

.search-form select {
    min-width: 160px;
    padding: 13px;
    border: 1px solid #343b60;
    border-radius: 8px;
    background: #10172b;
    color: white;
    font-size: 15px;
    cursor: pointer;
}

.search-form button {
    padding: 13px 22px;
    border: none;
    border-radius: 8px;
    background: #7c3aed;
    color: white;
    font-weight: bold;
    cursor: pointer;
}

.search-form button:hover {
    background: #6d28d9;
}

.clear-btn {
    padding: 13px 18px;
    border-radius: 8px;
    background: #334155;
    color: white;
    text-decoration: none;
}

/* STUDENT TABLE */

.table-card {
    background: #151c31;
    border: 1px solid #343b60;
    border-radius: 15px;
    padding: 22px;
    overflow-x: auto;
}

table {
    width: 100%;
    min-width: 1400px;
    border-collapse: collapse;
    table-layout: fixed;
}

th, td {
    padding: 18px 14px;
    text-align: left;
    vertical-align: middle;
    border-bottom: 1px solid #343b60;
}

th {
    color: #a78bfa;
    background: #10172b;
    font-size: 15px;
    white-space: nowrap;
}

td {
    color: #cbd5e1;
    font-size: 14px;
    overflow-wrap: anywhere;
}

th:nth-child(1), td:nth-child(1) { width: 6%; }
th:nth-child(2), td:nth-child(2) { width: 10%; }
th:nth-child(3), td:nth-child(3) { width: 22%; }
th:nth-child(4), td:nth-child(4) { width: 8%; }
th:nth-child(5), td:nth-child(5) { width: 10%; }
th:nth-child(6), td:nth-child(6) { width: 14%; }
th:nth-child(7), td:nth-child(7) { width: 11%; }
th:nth-child(8), td:nth-child(8) { width: 19%; }

tr:hover {
    background: #202a45;
}

.date-cell {
    white-space: nowrap;
    font-size: 13px;
}

/* ACCOUNT STATUS */

.account-status {
    display: inline-block;
    padding: 8px 13px;
    border-radius: 20px;
    font-size: 13px;
    font-weight: bold;
    white-space: nowrap;
}

.account-status.active {
    background: #123d30;
    color: #4ade80;
}

.account-status.inactive {
    background: #451f2a;
    color: #fca5a5;
}

/* ACTION BUTTONS */

.student-actions {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: nowrap;
    white-space: nowrap;
}

.student-actions form {
    margin: 0;
    display: inline-flex;
    flex-shrink: 0;
}

.student-actions .action-btn,
.student-actions button {
    flex-shrink: 0;
}
.student-actions form {
    margin: 0;
}

.student-actions .action-btn,
.student-actions button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 10px 12px;
    border: none;
    border-radius: 7px;
    color: white;
    text-decoration: none;
    font-size: 12px;
    font-weight: bold;
    white-space: nowrap;
    cursor: pointer;
}

.student-actions .action-btn {
    background: linear-gradient(90deg, #8b5cf6, #6d28d9);
}

.student-actions .action-btn:hover {
    background: #7c3aed;
}

.student-actions .deactivate-btn {
    background: #dc2626;
}

.student-actions .deactivate-btn:hover {
    background: #b91c1c;
}

.student-actions .activate-btn {
    background: #16a34a;
}

.student-actions .activate-btn:hover {
    background: #15803d;
}

/* MESSAGES */

.empty {
    text-align: center;
    padding: 30px;
    color: #94a3b8;
}

.error {
    background: #451f2a;
    color: #fca5a5;
    padding: 14px;
    border-radius: 9px;
    margin-bottom: 20px;
}

/* MOBILE */

@media(max-width:600px) {

    .container {
        padding: 12px;
    }

    .search-form {
        flex-direction: column;
    }

    .search-form input,
    .search-form select,
    .search-form button,
    .clear-btn {
        width: 100%;
        box-sizing: border-box;
        text-align: center;
    }

}
th:nth-child(3),
td:nth-child(3) {
    white-space: nowrap;
    overflow-wrap: normal;
}
</style>

</head>

<body>

<div class="container">

    <a href="admin-dashboard.jsp" class="back-btn">
        ← Back to Dashboard
    </a>

    <h1>👨‍🎓 Student Management</h1>

    <p class="subtitle">
        View all registered CodeAura students and their progress.
    </p>

    <!-- TOTAL STUDENTS COUNT -->

    <%
        try (Connection con = DBConnection.getConnection();

             PreparedStatement countPs = con.prepareStatement(
                 "SELECT COUNT(*) FROM users"
             );

             ResultSet countRs = countPs.executeQuery()) {

            if (countRs.next()) {
                studentCount = countRs.getInt(1);
            }

        } catch (Exception e) {

            application.log("Error counting students", e);

            dbError = "Unable to load student count.";
        }
    %>

    <div class="stats-card">

        <h3>Total Registered Students</h3>

        <p><%= studentCount %></p>

    </div>

    <% if (dbError != null) { %>

        <div class="error">
            <%= dbError %>
        </div>

    <% } %>

    <!-- SEARCH AND LEVEL FILTER -->

    <form action="view-students.jsp"
          method="get"
          class="search-form">

        <input type="text"
               name="search"
               placeholder="Search by username or email..."
               value="<%= escapeHTML(search) %>">

        <select name="level">

            <option value="0"
                <%= levelFilter == 0 ? "selected" : "" %>>
                All Levels
            </option>

            <option value="1"
                <%= levelFilter == 1 ? "selected" : "" %>>
                Level 1
            </option>

            <option value="2"
                <%= levelFilter == 2 ? "selected" : "" %>>
                Level 2
            </option>

            <option value="3"
                <%= levelFilter == 3 ? "selected" : "" %>>
                Level 3
            </option>

            <option value="4"
                <%= levelFilter == 4 ? "selected" : "" %>>
                Level 4
            </option>

            <option value="5"
                <%= levelFilter == 5 ? "selected" : "" %>>
                Level 5
            </option>

        </select>

        <button type="submit">
            🔍 Search
        </button>

        <a href="view-students.jsp" class="clear-btn">
            Clear
        </a>

    </form>

    <!-- STUDENT TABLE -->

    <div class="table-card">

        <table>

            <thead>

                <tr>
                    <th>Student ID</th>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Total XP</th>
                    <th>Player Level</th>
                    <th>Registered Date</th>
                    <th>Account Status</th>
                    <th>Actions</th>
                </tr>

            </thead>

            <tbody>

            <%

                boolean hasStudents = false;

                try (Connection con = DBConnection.getConnection();

                     PreparedStatement ps = con.prepareStatement(

                         "SELECT id, username, email, total_xp, " +
                         "player_level, created_at, account_status FROM users " +
                         "WHERE (username LIKE ? OR email LIKE ?) " +
                         "AND (? = 0 OR player_level = ?) " +
                         "ORDER BY id DESC"

                     )) {

                    ps.setString(1, "%" + search + "%");
                    ps.setString(2, "%" + search + "%");
                    ps.setInt(3, levelFilter);
                    ps.setInt(4, levelFilter);

                    try (ResultSet rs = ps.executeQuery()) {

                        while (rs.next()) {

                            hasStudents = true;

                            String accountStatus =
                                rs.getString("account_status");

            %>

                <tr>

                    <td>
                        <%= rs.getInt("id") %>
                    </td>

                    <td>
                        <%= escapeHTML(rs.getString("username")) %>
                    </td>

                    <td>
                        <%= escapeHTML(rs.getString("email")) %>
                    </td>

                    <td>
                        <%= rs.getInt("total_xp") %> XP
                    </td>

                    <td>
                        Level <%= rs.getInt("player_level") %>
                    </td>

                    <td class="date-cell">
                        <%= rs.getTimestamp("created_at") %>
                    </td>

                    <!-- ACCOUNT STATUS -->

                    <td>

                        <% if ("ACTIVE".equals(accountStatus)) { %>

                            <span class="account-status active">
                                ACTIVE
                            </span>

                        <% } else { %>

                            <span class="account-status inactive">
                                INACTIVE
                            </span>

                        <% } %>

                    </td>

                    <!-- ACTION BUTTONS -->

                    <td>

                        <div class="student-actions">

                            <a href="student-details.jsp?id=<%= rs.getInt("id") %>"
                               class="action-btn">
                                👁 View Details
                            </a>

                            <form action="UpdateStudentStatusServlet"
                                  method="post">

                                <input type="hidden"
                                       name="id"
                                       value="<%= rs.getInt("id") %>">

                                <% if ("ACTIVE".equals(accountStatus)) { %>

                                    <input type="hidden"
                                           name="status"
                                           value="INACTIVE">

                                    <button type="submit"
                                            class="deactivate-btn"
                                            onclick="return confirm('Deactivate this student?');">
                                        Deactivate
                                    </button>

                                <% } else { %>

                                    <input type="hidden"
                                           name="status"
                                           value="ACTIVE">

                                    <button type="submit"
                                            class="activate-btn"
                                            onclick="return confirm('Activate this student?');">
                                        Activate
                                    </button>

                                <% } %>

                            </form>

                        </div>

                    </td>

                </tr>

            <%

                        }

                    }

                } catch (Exception e) {

                    application.log("Error loading students", e);

                    dbError = "Unable to load student records. Check database connection.";

                }

                if (dbError != null) {

            %>

                <tr>

                    <td colspan="8" class="empty">
                        <%= dbError %>
                    </td>

                </tr>

            <%

                } else if (!hasStudents) {

            %>

                <tr>

                    <td colspan="8" class="empty">

                        <% if (!search.isEmpty()) { %>

                            No students found matching:
                            <strong><%= escapeHTML(search) %></strong>

                        <% } else { %>

                            No registered students found.

                        <% } %>

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
