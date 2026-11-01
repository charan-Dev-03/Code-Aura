
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*" %>
<%@ page import="com.codeaura.db.DBConnection" %>

<%
if (!Boolean.TRUE.equals(session.getAttribute("adminLoggedIn"))) {
    response.sendRedirect("admin-login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Notifications - CodeAura</title>

<style>
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    padding: 25px;
    font-family: Arial, sans-serif;
    background: #100d20;
    color: white;
}

.container {
    max-width: 1100px;
    margin: auto;
}

h1 {
    color: #c4a5ff;
}

.card {
    background: #211b38;
    padding: 22px;
    margin-top: 22px;
    border-radius: 12px;
    border: 1px solid #40345f;
}

label {
    display: block;
    margin: 15px 0 7px;
}

input, textarea, select {
    width: 100%;
    padding: 12px;
    border: 1px solid #554779;
    border-radius: 7px;
    background: #17132a;
    color: white;
}

textarea {
    min-height: 100px;
    resize: vertical;
}

button {
    margin-top: 16px;
    padding: 12px 20px;
    border: none;
    border-radius: 7px;
    background: #8955e8;
    color: white;
    font-weight: bold;
    cursor: pointer;
}

button:hover {
    background: #a47aff;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 15px;
    min-width: 750px;
}

th, td {
    padding: 13px;
    text-align: left;
    border-bottom: 1px solid #40345f;
}

th {
    color: #c4a5ff;
}

.table-wrapper {
    overflow-x: auto;
}

.status {
    color: #70e6a0;
    font-weight: bold;
}

.delete-btn {
    background: #d94359;
    margin: 0;
}

.delete-btn:hover {
    background: #f15a70;
}

.message {
    padding: 12px;
    margin-top: 15px;
    border-radius: 7px;
    background: #173d2b;
    color: #8ff0b4;
}

.error {
    background: #491e2a;
    color: #ff9aaa;
}

.back {
    display: inline-block;
    color: #c4a5ff;
    margin-top: 15px;
    text-decoration: none;
}

@media(max-width: 600px) {
    body {
        padding: 12px;
    }

    .card {
        padding: 15px;
    }
}
</style>
</head>

<body>

<div class="container">

<h1>CodeAura Admin Notifications</h1>
<p>Send announcements and manage student notifications.</p>

<a class="back" href="admin-dashboard.jsp">
    ← Back to Admin Dashboard
</a>

<%
String success = request.getParameter("success");
String error = request.getParameter("error");

if ("sent".equals(success)) {
%>
<div class="message">Notification sent successfully!</div>
<%
} else if ("deleted".equals(success)) {
%>
<div class="message">Notification deleted successfully!</div>
<%
}

if ("1".equals(error)) {
%>
<div class="message error">Unable to complete the operation.</div>
<%
}
%>

<!-- SEND NOTIFICATION -->

<div class="card">

<h2>Send Notification</h2>

<form action="AdminNotificationServlet" method="post">

<label>Notification Recipient</label>

<select name="recipientType" id="recipientType"
        onchange="toggleStudentField()" required>

    <option value="ALL">All Students</option>
    <option value="INDIVIDUAL">Individual Student</option>

</select>

<div id="studentField" style="display:none;">

    <label>Select Student</label>

    <select name="userId" id="userId">

        <option value="">Select Student</option>

        <%
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT id, username, email FROM users ORDER BY username");
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
        %>

        <option value="<%= rs.getInt("id") %>">
            <%= rs.getString("username") %>
            (<%= rs.getString("email") %>)
        </option>

        <%
            }
        } catch (Exception e) {
            application.log("Unable to load students", e);
        }
        %>

    </select>

</div>

<label>Notification Title</label>
<input type="text" name="title"
       maxlength="150" required
       placeholder="Enter notification title">

<label>Notification Message</label>
<textarea name="message" maxlength="500"
          required placeholder="Enter notification message"></textarea>

<label>Notification Type</label>

<select name="notificationType" required>
    <option value="ANNOUNCEMENT">Announcement</option>
    <option value="MISSION">Mission</option>
    <option value="GENERAL">General</option>
</select>

<button type="submit">Send Notification</button>

</form>

</div>

<!-- NOTIFICATION HISTORY -->

<div class="card">

<h2>Notification History</h2>

<div class="table-wrapper">

<table>

<tr>
    <th>ID</th>
    <th>Student ID</th>
    <th>Title</th>
    <th>Message</th>
    <th>Type</th>
    <th>Status</th>
    <th>Date</th>
    <th>Action</th>
</tr>

<%
try (Connection con = DBConnection.getConnection();
     PreparedStatement ps = con.prepareStatement(
         "SELECT n.id, n.user_id, n.title, n.message, " +
         "n.notification_type, n.is_read, n.created_at, u.username " +
         "FROM notifications n " +
         "LEFT JOIN users u ON n.user_id = u.id " +
         "ORDER BY n.created_at DESC, n.id DESC");
     ResultSet rs = ps.executeQuery()) {

    while (rs.next()) {
%>

<tr>
    <td><%= rs.getInt("id") %></td>
    <td>
        <%= rs.getInt("user_id") %>
        - <%= rs.getString("username") == null
              ? "Deleted Student"
              : rs.getString("username") %>
    </td>
    <td><%= rs.getString("title") %></td>
    <td><%= rs.getString("message") %></td>
    <td><%= rs.getString("notification_type") %></td>

    <td class="status">
        <%= rs.getBoolean("is_read") ? "READ" : "UNREAD" %>
    </td>

    <td><%= rs.getTimestamp("created_at") %></td>

    <td>
        <form action="AdminNotificationServlet"
              method="post"
              onsubmit="return confirm('Delete this notification?');">

            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="notificationId"
                   value="<%= rs.getInt("id") %>">

            <button type="submit" class="delete-btn">
                Delete
            </button>

        </form>
    </td>
</tr>

<%
    }

} catch (Exception e) {
    application.log("Unable to load notification history", e);
%>

<tr>
    <td colspan="8">Unable to load notification history.</td>
</tr>

<%
}
%>

</table>

</div>
</div>

</div>

<script>
function toggleStudentField() {

    const recipient = document.getElementById("recipientType").value;
    const studentField = document.getElementById("studentField");
    const userId = document.getElementById("userId");

    if (recipient === "INDIVIDUAL") {
        studentField.style.display = "block";
        userId.required = true;
    } else {
        studentField.style.display = "none";
        userId.required = false;
        userId.value = "";
    }
}
</script>

</body>
</html>
