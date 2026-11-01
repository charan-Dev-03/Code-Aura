
package com.codeaura.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import com.codeaura.db.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/DeleteMissionServlet")
public class DeleteMissionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String contextPath = request.getContextPath();

        // Check administrator login
        HttpSession session = request.getSession(false);

        if (session == null ||
            !Boolean.TRUE.equals(session.getAttribute("adminLoggedIn"))) {

            response.sendRedirect(contextPath + "/admin-login.jsp");
            return;
        }

        // Get mission ID
        String missionIdValue = request.getParameter("id");

        if (missionIdValue == null || missionIdValue.trim().isEmpty()) {

            response.sendRedirect(
                contextPath + "/manage-missions.jsp?error=invalid");

            return;
        }

        try {

            int missionId = Integer.parseInt(missionIdValue);

            if (missionId <= 0) {

                response.sendRedirect(
                    contextPath + "/manage-missions.jsp?error=invalid");

                return;
            }

            String sql = "DELETE FROM missions WHERE id = ?";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, missionId);

                int result = ps.executeUpdate();

                if (result == 1) {

                    response.sendRedirect(
                        contextPath + "/manage-missions.jsp?deleted=1");

                } else {

                    response.sendRedirect(
                        contextPath + "/manage-missions.jsp?error=notfound");
                }
            }

        } catch (NumberFormatException e) {

            response.sendRedirect(
                contextPath + "/manage-missions.jsp?error=invalid");

        } catch (SQLException e) {

            getServletContext().log("Error deleting mission", e);

            // Foreign key constraint or database error
            if ("23000".equals(e.getSQLState())) {

                response.sendRedirect(
                    contextPath +
                    "/manage-missions.jsp?error=submissions");

            } else {

                response.sendRedirect(
                    contextPath + "/manage-missions.jsp?error=1");
            }

        } catch (Exception e) {

            getServletContext().log("Unexpected mission deletion error", e);

            response.sendRedirect(
                contextPath + "/manage-missions.jsp?error=1");
        }
    }
}
