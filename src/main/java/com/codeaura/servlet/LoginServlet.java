
package com.codeaura.servlet;

import java.io.IOException;
import java.security.MessageDigest;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.codeaura.db.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private boolean verifyPassword(
            String password, String storedHash) throws Exception {

        String[] parts = storedHash.split(":");

        if (parts.length != 3) {
            return false;
        }

        int iterations = Integer.parseInt(parts[0]);

        if (iterations < 10000 || iterations > 1000000) {
            return false;
        }

        byte[] salt = Base64.getDecoder().decode(parts[1]);
        byte[] originalHash = Base64.getDecoder().decode(parts[2]);

        PBEKeySpec spec = new PBEKeySpec(
            password.toCharArray(),
            salt,
            iterations,
            originalHash.length * 8
        );

        try {
            SecretKeyFactory factory =
                SecretKeyFactory.getInstance(
                    "PBKDF2WithHmacSHA256"
                );

            byte[] newHash =
                factory.generateSecret(spec).getEncoded();

            return MessageDigest.isEqual(
                originalHash, newHash
            );

        } finally {
            spec.clearPassword();
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String loginInput = request.getParameter("loginInput");
        String password = request.getParameter("password");

        try {

            if (loginInput == null || password == null ||
                loginInput.trim().isEmpty() || password.isEmpty()) {

                throw new IllegalArgumentException(
                    "Please enter your login details."
                );
            }

            String sql =
                "SELECT id, username, password, total_xp, " +
                "player_level, account_status " +
                "FROM users WHERE username=? OR email=?";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setString(1, loginInput.trim());
                ps.setString(2, loginInput.trim());

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {

                        String storedHash = rs.getString("password");

                        if (verifyPassword(password, storedHash)) {

                            String accountStatus =
                                rs.getString("account_status");

                            // CHECK STUDENT ACCOUNT STATUS

                            if (!"ACTIVE".equals(accountStatus)) {

                                request.setAttribute(
                                    "errorMessage",
                                    "Your account has been deactivated. Please contact the administrator."
                                );

                            } else {

                                // ALLOW ACTIVE STUDENT TO LOGIN

                                HttpSession session =
                                    request.getSession(true);

                                request.changeSessionId();

                                session.setAttribute(
                                    "userId", rs.getInt("id")
                                );

                                session.setAttribute(
                                    "username", rs.getString("username")
                                );

                                session.setAttribute(
                                    "totalXP", rs.getInt("total_xp")
                                );

                                session.setAttribute(
                                    "playerLevel", rs.getInt("player_level")
                                );

                                session.setAttribute(
                                    "userLoggedIn", true
                                );

                                session.setMaxInactiveInterval(30 * 60);

                                response.sendRedirect("dashboard.jsp");

                                return;
                            }
                        }
                    }
                }
            }

            // SHOW GENERAL ERROR IF NO OTHER MESSAGE EXISTS

            if (request.getAttribute("errorMessage") == null) {

                request.setAttribute(
                    "errorMessage",
                    "Invalid username/email or password."
                );
            }

        } catch (IllegalArgumentException e) {

            request.setAttribute(
                "errorMessage", e.getMessage()
            );

        } catch (Exception e) {

            getServletContext().log("Student login failed", e);

            request.setAttribute(
                "errorMessage",
                "Login failed. Please try again."
            );
        }

        request.getRequestDispatcher("login.jsp")
               .forward(request, response);
    }
}
