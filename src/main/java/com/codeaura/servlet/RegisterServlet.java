
package com.codeaura.servlet;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.security.spec.KeySpec;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

import com.codeaura.db.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int ITERATIONS = 65536;
    private static final int KEY_LENGTH = 256;

    private String hashPassword(String password) throws Exception {

        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);

        KeySpec spec = new PBEKeySpec(
            password.toCharArray(),
            salt,
            ITERATIONS,
            KEY_LENGTH
        );

        SecretKeyFactory factory =
            SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");

        byte[] hash = factory.generateSecret(spec).getEncoded();

        return ITERATIONS + ":" +
            Base64.getEncoder().encodeToString(salt) + ":" +
            Base64.getEncoder().encodeToString(hash);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword =
            request.getParameter("confirmPassword");

        try {

            if (username == null || email == null ||
                password == null || confirmPassword == null) {

                throw new IllegalArgumentException(
                    "Please fill in all fields."
                );
            }

            username = username.trim();
            email = email.trim();

            if (username.isEmpty() || email.isEmpty() ||
                password.isEmpty() || confirmPassword.isEmpty()) {

                throw new IllegalArgumentException(
                    "All fields are required."
                );
            }

            if (username.length() > 50 || email.length() > 100) {
                throw new IllegalArgumentException(
                    "Username or email is too long."
                );
            }

            if (password.length() < 8) {
                throw new IllegalArgumentException(
                    "Password must contain at least 8 characters."
                );
            }

            if (!password.equals(confirmPassword)) {
                throw new IllegalArgumentException(
                    "Passwords do not match."
                );
            }

            if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                throw new IllegalArgumentException(
                    "Please enter a valid email address."
                );
            }

            try (Connection con = DBConnection.getConnection()) {

                String checkSql =
                    "SELECT id FROM users WHERE username=? OR email=?";

                try (PreparedStatement check =
                    con.prepareStatement(checkSql)) {

                    check.setString(1, username);
                    check.setString(2, email);

                    try (ResultSet rs = check.executeQuery()) {

                        if (rs.next()) {
                            throw new IllegalArgumentException(
                                "Username or email already exists."
                            );
                        }
                    }
                }

                String hashedPassword = hashPassword(password);

                String insertSql =
                    "INSERT INTO users " +
                    "(username, email, password, total_xp, player_level) " +
                    "VALUES (?, ?, ?, 0, 1)";

                try (PreparedStatement ps =
                    con.prepareStatement(insertSql)) {

                    ps.setString(1, username);
                    ps.setString(2, email);
                    ps.setString(3, hashedPassword);

                    int result = ps.executeUpdate();

                    if (result > 0) {
                        request.setAttribute(
                            "successMessage",
                            "Registration successful! Welcome to CodeAura."
                        );
                        request.setAttribute("registrationSuccess", true);
                    } else {
                        throw new SQLException(
                            "Unable to register student."
                        );
                    }
                }
            }

        } catch (IllegalArgumentException e) {

            request.setAttribute("errorMessage", e.getMessage());

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                "errorMessage",
                "Registration failed. Please check your details and try again."
            );
        }

        request.getRequestDispatcher("register.jsp")
               .forward(request, response);
    }
}
