
package com.codeaura.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import com.codeaura.db.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/UpdateStudentStatusServlet")
public class UpdateStudentStatusServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
                          throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // CHECK ADMIN LOGIN

        if (session == null ||
            !Boolean.TRUE.equals(session.getAttribute("adminLoggedIn"))) {

            response.sendRedirect("admin-login.jsp");
            return;
        }

        // GET FORM DATA

        String studentIdParam = request.getParameter("id");
        String status = request.getParameter("status");

        int studentId;

        try {

            studentId = Integer.parseInt(studentIdParam);

            if (studentId <= 0) {
                response.sendRedirect("view-students.jsp?error=invalid");
                return;
            }

        } catch (Exception e) {

            response.sendRedirect("view-students.jsp?error=invalid");
            return;
        }

        // VALIDATE STATUS

        if (!"ACTIVE".equals(status) &&
            !"INACTIVE".equals(status)) {

            response.sendRedirect("view-students.jsp?error=invalid");
            return;
        }

        // UPDATE STUDENT STATUS

        String sql = "UPDATE users SET account_status = ? WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, studentId);

            int rows = ps.executeUpdate();

            if (rows > 0) {

                response.sendRedirect(
                    "view-students.jsp?statusUpdated=1"
                );

            } else {

                response.sendRedirect(
                    "view-students.jsp?error=notfound"
                );
            }

        } catch (Exception e) {

            applicationLog(e);

            response.sendRedirect(
                "view-students.jsp?error=database"
            );
        }
    }

    private void applicationLog(Exception e) {
        getServletContext().log(
            "Error updating student account status", e
        );
    }
}
