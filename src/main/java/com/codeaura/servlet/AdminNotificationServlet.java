
package com.codeaura.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.codeaura.db.DBConnection;

@WebServlet("/AdminNotificationServlet")
public class AdminNotificationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        // Check admin login
        if (session == null ||
            !Boolean.TRUE.equals(session.getAttribute("adminLoggedIn"))) {

            response.sendRedirect("admin-login.jsp");
            return;
        }

        String action = request.getParameter("action");

        // Delete notification
        if ("delete".equals(action)) {
            deleteNotification(request, response);
            return;
        }

        // Otherwise, send notification
        sendNotification(request, response);
    }

    // ------------------------------------------
    // SEND NOTIFICATION
    // ------------------------------------------

    private void sendNotification(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String recipientType = request.getParameter("recipientType");
        String title = request.getParameter("title");
        String message = request.getParameter("message");
        String notificationType =
            request.getParameter("notificationType");

        if (recipientType == null ||
            title == null ||
            message == null ||
            notificationType == null) {

            response.sendRedirect(
                "admin-notifications.jsp?error=1"
            );
            return;
        }

        title = title.trim();
        message = message.trim();

        if (title.isEmpty() ||
            message.isEmpty() ||
            title.length() > 150 ||
            message.length() > 500) {

            response.sendRedirect(
                "admin-notifications.jsp?error=1"
            );
            return;
        }

        // Allow only supported notification types
        if (!notificationType.equals("ANNOUNCEMENT") &&
            !notificationType.equals("MISSION") &&
            !notificationType.equals("GENERAL")) {

            response.sendRedirect(
                "admin-notifications.jsp?error=1"
            );
            return;
        }

        if (!recipientType.equals("ALL") &&
            !recipientType.equals("INDIVIDUAL")) {

            response.sendRedirect(
                "admin-notifications.jsp?error=1"
            );
            return;
        }

        Connection con = null;

        try {
            con = DBConnection.getConnection();

            if (con == null) {
                throw new Exception("Database connection failed.");
            }

            con.setAutoCommit(false);

            int notificationsSent = 0;

            if ("ALL".equals(recipientType)) {

                // Send to all active students
                String sql =
                    "INSERT INTO notifications " +
                    "(user_id, title, message, notification_type) " +
                    "SELECT id, ?, ?, ? FROM users " +
                    "WHERE account_status = 'ACTIVE'";

                try (PreparedStatement ps =
                        con.prepareStatement(sql)) {

                    ps.setString(1, title);
                    ps.setString(2, message);
                    ps.setString(3, notificationType);

                    notificationsSent = ps.executeUpdate();
                }

            } else {

                // Send to one selected active student
                int userId;

                try {
                    userId = Integer.parseInt(
                        request.getParameter("userId")
                    );
                } catch (Exception e) {
                    con.rollback();

                    response.sendRedirect(
                        "admin-notifications.jsp?error=1"
                    );
                    return;
                }

                if (userId <= 0) {
                    con.rollback();

                    response.sendRedirect(
                        "admin-notifications.jsp?error=1"
                    );
                    return;
                }

                // Check whether the student exists and is active
                String checkSql =
                    "SELECT id FROM users " +
                    "WHERE id = ? AND account_status = 'ACTIVE'";

                try (PreparedStatement ps =
                        con.prepareStatement(checkSql)) {

                    ps.setInt(1, userId);

                    try (ResultSet rs = ps.executeQuery()) {

                        if (!rs.next()) {
                            con.rollback();

                            response.sendRedirect(
                                "admin-notifications.jsp?error=1"
                            );
                            return;
                        }
                    }
                }

                String insertSql =
                    "INSERT INTO notifications " +
                    "(user_id, title, message, notification_type) " +
                    "VALUES (?, ?, ?, ?)";

                try (PreparedStatement ps =
                        con.prepareStatement(insertSql)) {

                    ps.setInt(1, userId);
                    ps.setString(2, title);
                    ps.setString(3, message);
                    ps.setString(4, notificationType);

                    notificationsSent = ps.executeUpdate();
                }
            }

            if (notificationsSent <= 0) {
                con.rollback();

                response.sendRedirect(
                    "admin-notifications.jsp?error=1"
                );
                return;
            }

            con.commit();

            response.sendRedirect(
                "admin-notifications.jsp?success=sent"
            );

        } catch (Exception e) {

            if (con != null) {
                try {
                    con.rollback();
                } catch (Exception rollbackError) {
                    log("Notification rollback failed", rollbackError);
                }
            }

            log("Admin notification sending failed", e);

            response.sendRedirect(
                "admin-notifications.jsp?error=1"
            );

        } finally {

            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (Exception e) {
                    log("Database connection closing failed", e);
                }
            }
        }
    }

    // ------------------------------------------
    // DELETE NOTIFICATION
    // ------------------------------------------

    private void deleteNotification(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        int notificationId;

        try {
            notificationId = Integer.parseInt(
                request.getParameter("notificationId")
            );

            if (notificationId <= 0) {
                throw new NumberFormatException();
            }

        } catch (Exception e) {

            response.sendRedirect(
                "admin-notifications.jsp?error=1"
            );
            return;
        }

        String sql =
            "DELETE FROM notifications WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, notificationId);

            int deleted = ps.executeUpdate();

            if (deleted == 1) {

                response.sendRedirect(
                    "admin-notifications.jsp?success=deleted"
                );

            } else {

                response.sendRedirect(
                    "admin-notifications.jsp?error=1"
                );
            }

        } catch (Exception e) {

            log("Admin notification deletion failed", e);

            response.sendRedirect(
                "admin-notifications.jsp?error=1"
            );
        }
    }
}
