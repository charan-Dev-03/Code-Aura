
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.Timestamp" %>

<%
    if (!Boolean.TRUE.equals(session.getAttribute("userLoggedIn"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Map<String, Object>> notifications =
        (List<Map<String, Object>>) request.getAttribute("notifications");

    Integer unreadCount =
        (Integer) request.getAttribute("unreadCount");

    if (unreadCount == null) unreadCount = 0;

    String notificationError =
        (String) request.getAttribute("notificationError");
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Notifications | CodeAura</title>

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
    max-width: 1050px;
    margin: auto;
}

.header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 15px;
    margin-bottom: 30px;
}

h1 {
    color: #c5a3ff;
    font-size: 32px;
    margin-bottom: 8px;
}

.subtitle {
    color: #aaa;
}

.unread-counter {
    background: #8b5cf6;
    padding: 12px 18px;
    border-radius: 10px;
    font-weight: bold;
}

.notification-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.notification-card {
    background: #211b35;
    border: 1px solid #40345e;
    border-radius: 13px;
    padding: 22px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 20px;
    transition: 0.3s;
}

.notification-card:hover {
    border-color: #a78bfa;
    transform: translateY(-2px);
}

.notification-card.unread {
    border-left: 5px solid #a78bfa;
    background: #29213f;
}

.notification-content {
    flex: 1;
}

.notification-title {
    color: #d8c2ff;
    font-size: 19px;
    margin-bottom: 9px;
}

.notification-message {
    color: #ccc;
    line-height: 1.6;
    margin-bottom: 12px;
    overflow-wrap: anywhere;
}

.notification-meta {
    color: #999;
    font-size: 12px;
}

.type {
    display: inline-block;
    color: #c4b5fd;
    background: #393052;
    padding: 5px 10px;
    border-radius: 15px;
    font-size: 11px;
    margin-bottom: 12px;
}

.read-status {
    color: #4ade80;
    font-size: 12px;
    font-weight: bold;
}

.unread-status {
    color: #facc15;
    font-size: 12px;
    font-weight: bold;
}

.mark-btn {
    background: #8b5cf6;
    color: white;
    border: none;
    padding: 11px 16px;
    border-radius: 7px;
    cursor: pointer;
    white-space: nowrap;
}

.mark-btn:hover {
    background: #7c3aed;
}

.empty {
    background: #211b35;
    border: 1px solid #40345e;
    border-radius: 13px;
    padding: 45px 20px;
    text-align: center;
    color: #aaa;
    line-height: 1.8;
}

.error {
    color: #fb7185;
}

.back-btn {
    display: inline-block;
    margin-top: 30px;
    padding: 13px 23px;
    background: #8b5cf6;
    color: white;
    text-decoration: none;
    border-radius: 8px;
}

.back-btn:hover {
    background: #7c3aed;
}

@media(max-width: 650px) {

    body {
        padding: 18px;
    }

    .notification-card {
        flex-direction: column;
        align-items: flex-start;
    }

    .mark-btn {
        width: 100%;
    }

    h1 {
        font-size: 27px;
    }
}

</style>

</head>

<body>

<div class="container">

    <div class="header">

        <div>

            <h1>My Notifications</h1>

            <p class="subtitle">
                Stay updated with your CodeAura learning journey.
            </p>

        </div>

        <div class="unread-counter">
            Unread: <%= unreadCount %>
        </div>

    </div>


    <% if (notificationError != null) { %>

        <div class="empty error">
            <%= notificationError %>
        </div>

    <% } else if (notifications == null || notifications.isEmpty()) { %>

        <div class="empty">
            <h2>No Notifications Yet</h2>
            <p>You will see your updates here.</p>
        </div>

    <% } else { %>

        <div class="notification-list">

            <% for (Map<String, Object> n : notifications) {

                int id = (Integer) n.get("id");

                String title = (String) n.get("title");
                String message = (String) n.get("message");
                String type = (String) n.get("type");

                boolean isRead = (Boolean) n.get("isRead");

                Timestamp createdAt =
                    (Timestamp) n.get("createdAt");

                String safeTitle = title == null ? "" :
                    title.replace("&", "&amp;")
                         .replace("<", "&lt;")
                         .replace(">", "&gt;")
                         .replace("\"", "&quot;");

                String safeMessage = message == null ? "" :
                    message.replace("&", "&amp;")
                           .replace("<", "&lt;")
                           .replace(">", "&gt;")
                           .replace("\"", "&quot;");

                String safeType = type == null ? "" :
                    type.replace("&", "&amp;")
                        .replace("<", "&lt;")
                        .replace(">", "&gt;");

            %>

                <div class="notification-card <%= isRead ? "" : "unread" %>">

                    <div class="notification-content">

                        <span class="type">
                            <%= safeType %>
                        </span>

                        <h3 class="notification-title">
                            <%= safeTitle %>
                        </h3>

                        <p class="notification-message">
                            <%= safeMessage %>
                        </p>

                        <p class="notification-meta">

                            <%= createdAt != null ? createdAt : "Date unavailable" %>

                            &nbsp; | &nbsp;

                            <% if (isRead) { %>

                                <span class="read-status">
                                    READ
                                </span>

                            <% } else { %>

                                <span class="unread-status">
                                    UNREAD
                                </span>

                            <% } %>

                        </p>

                    </div>

                    <% if (!isRead) { %>

                        <form action="NotificationServlet" method="post">

                            <input type="hidden"
                                   name="notificationId"
                                   value="<%= id %>">

                            <button type="submit" class="mark-btn">
                                Mark as Read
                            </button>

                        </form>

                    <% } %>

                </div>

            <% } %>

        </div>

    <% } %>


    <a href="dashboard.jsp" class="back-btn">
        Back to Dashboard
    </a>

</div>

</body>
</html>
