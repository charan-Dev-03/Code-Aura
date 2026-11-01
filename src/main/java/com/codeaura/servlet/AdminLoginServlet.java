
package com.codeaura.servlet;

import java.io.IOException;
import java.security.MessageDigest;
import javax.crypto.spec.PBEKeySpec;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;

import com.codeaura.db.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {

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
                SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");

            byte[] newHash =
                factory.generateSecret(spec).getEncoded();

            return MessageDigest.isEqual(originalHash, newHash);

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

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {

            if (username == null || password == null ||
                username.trim().isEmpty() || password.isEmpty()) {

                throw new IllegalArgumentException(
                    "Please enter username and password."
                );
            }

            String sql =
                "SELECT id, username, password FROM admins WHERE username=?";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setString(1, username.trim());

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {

                        String storedHash = rs.getString("password");

                        if (verifyPassword(password, storedHash)) {

                            HttpSession session =
                                request.getSession(true);

                            request.changeSessionId();

                            session.setAttribute(
                                "adminId", rs.getInt("id")
                            );

                            session.setAttribute(
                                "adminUsername", rs.getString("username")
                            );

                            session.setAttribute(
                                "adminLoggedIn", true
                            );

                            session.setMaxInactiveInterval(30 * 60);

                            response.sendRedirect("admin-dashboard.jsp");

                            return;
                        }
                    }
                }
            }

            request.setAttribute(
                "errorMessage",
                "Invalid administrator username or password."
            );

        } catch (IllegalArgumentException e) {

            request.setAttribute(
                "errorMessage", e.getMessage()
            );

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                "errorMessage",
                "Admin login failed. Please try again."
            );
        }

        request.getRequestDispatcher("admin-login.jsp")
               .forward(request, response);
    }
}
