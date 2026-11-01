
package com.codeaura.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.codeaura.db.DBConnection;

@WebServlet("/NotificationServlet")
public class NotificationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // DISPLAY STUDENT NOTIFICATIONS
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
                         throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null ||
            !Boolean.TRUE.equals(session.getAttribute("userLoggedIn"))) {

            response.sendRedirect("login.jsp");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        List<Map<String, Object>> notifications =
                new ArrayList<>();

        int unreadCount = 0;

        String sql =
            "SELECT id, title, message, notification_type, " +
            "is_read, created_at " +
            "FROM notifications " +
            "WHERE user_id = ? " +
            "ORDER BY created_at DESC, id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    Map<String, Object> notification =
                            new HashMap<>();

                    notification.put("id", rs.getInt("id"));
                    notification.put("title", rs.getString("title"));
                    notification.put("message", rs.getString("message"));

                    notification.put(
                        "type",
                        rs.getString("notification_type")
                    );

                    boolean isRead = rs.getBoolean("is_read");

                    notification.put("isRead", isRead);

                    notification.put(
                        "createdAt",
                        rs.getTimestamp("created_at")
                    );

                    if (!isRead) {
                        unreadCount++;
                    }

                    notifications.add(notification);
                }
            }

            request.setAttribute("notifications", notifications);
            request.setAttribute("unreadCount", unreadCount);

            request.getRequestDispatcher(
                "/notifications.jsp"
            ).forward(request, response);

        } catch (Exception e) {

            getServletContext().log(
                "Error loading student notifications", e
            );

            request.setAttribute(
                "notificationError",
                "Unable to load notifications. Please try again."
            );

            request.getRequestDispatcher(
                "/notifications.jsp"
            ).forward(request, response);
        }
    }


    // MARK A NOTIFICATION AS READ
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
                          throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null ||
            !Boolean.TRUE.equals(session.getAttribute("userLoggedIn"))) {

            response.sendRedirect("login.jsp");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String notificationId = request.getParameter("notificationId");

        try {

            int id = Integer.parseInt(notificationId);

            String sql =
                "UPDATE notifications SET is_read = TRUE " +
                "WHERE id = ? AND user_id = ?";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, id);
                ps.setInt(2, userId);

                ps.executeUpdate();
            }

            response.sendRedirect(
                request.getContextPath() + "/NotificationServlet"
            );

        } catch (NumberFormatException e) {

            response.sendRedirect(
                request.getContextPath() + "/NotificationServlet"
            );

        } catch (Exception e) {

            getServletContext().log(
                "Error updating notification", e
            );

            response.sendRedirect(
                request.getContextPath() + "/NotificationServlet"
            );
        }
    }
}
