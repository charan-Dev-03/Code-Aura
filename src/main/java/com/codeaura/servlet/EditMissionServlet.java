
package com.codeaura.servlet;

import java.io.IOException;
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

@WebServlet("/EditMissionServlet")
public class EditMissionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // Check administrator login
    private boolean isAdminLoggedIn(HttpServletRequest request) {

        HttpSession session = request.getSession(false);

        return session != null &&
            Boolean.TRUE.equals(session.getAttribute("adminLoggedIn"));
    }

    // OPEN EXISTING MISSION FOR EDITING
    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdminLoggedIn(request)) {
            response.sendRedirect(
                request.getContextPath() + "/admin-login.jsp");
            return;
        }

        try {

            int id = Integer.parseInt(request.getParameter("id"));

            String sql = "SELECT * FROM missions WHERE id = ?";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, id);

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {

                        request.setAttribute("id", rs.getInt("id"));
                        request.setAttribute("title", rs.getString("title"));
                        request.setAttribute("description", rs.getString("description"));
                        request.setAttribute("category", rs.getString("category"));
                        request.setAttribute("difficulty", rs.getString("difficulty"));

                        request.setAttribute("option_a", rs.getString("option_a"));
                        request.setAttribute("option_b", rs.getString("option_b"));
                        request.setAttribute("option_c", rs.getString("option_c"));
                        request.setAttribute("option_d", rs.getString("option_d"));

                        request.setAttribute("correct_answer",
                            rs.getString("correct_answer"));

                        request.setAttribute("xp_reward",
                            rs.getInt("xp_reward"));

                        request.getRequestDispatcher(
                            "/edit-mission.jsp").forward(request, response);

                    } else {

                        response.sendRedirect(
                            request.getContextPath() +
                            "/manage-missions.jsp?error=notfound");
                    }
                }
            }

        } catch (NumberFormatException e) {

            response.sendRedirect(
                request.getContextPath() +
                "/manage-missions.jsp?error=invalid");

        } catch (Exception e) {

            getServletContext().log("Error loading mission", e);

            response.sendRedirect(
                request.getContextPath() +
                "/manage-missions.jsp?error=1");
        }
    }

    // UPDATE MISSION
    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!isAdminLoggedIn(request)) {
            response.sendRedirect(
                request.getContextPath() + "/admin-login.jsp");
            return;
        }

        try {

            int id = Integer.parseInt(request.getParameter("id"));

            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String category = request.getParameter("category");
            String difficulty = request.getParameter("difficulty");

            String optionA = request.getParameter("option_a");
            String optionB = request.getParameter("option_b");
            String optionC = request.getParameter("option_c");
            String optionD = request.getParameter("option_d");

            String correctChoice = request.getParameter("correct_answer");
            String xpValue = request.getParameter("xp_reward");

            if (title == null || description == null ||
                category == null || difficulty == null ||
                optionA == null || optionB == null ||
                optionC == null || optionD == null ||
                correctChoice == null || xpValue == null) {

                response.sendRedirect(
                    request.getContextPath() +
                    "/EditMissionServlet?id=" + id + "&error=1");
                return;
            }

            title = title.trim();
            description = description.trim();

            optionA = optionA.trim();
            optionB = optionB.trim();
            optionC = optionC.trim();
            optionD = optionD.trim();

            if (title.isEmpty() || title.length() > 100 ||
                description.isEmpty() ||
                optionA.isEmpty() || optionA.length() > 255 ||
                optionB.isEmpty() || optionB.length() > 255 ||
                optionC.isEmpty() || optionC.length() > 255 ||
                optionD.isEmpty() || optionD.length() > 255 ||
                !category.matches("Java|SQL|DSA") ||
                !difficulty.matches("Easy|Medium|Hard")) {

                response.sendRedirect(
                    request.getContextPath() +
                    "/EditMissionServlet?id=" + id + "&error=1");
                return;
            }

            String correctAnswer;

            switch (correctChoice) {

                case "A":
                    correctAnswer = optionA;
                    break;

                case "B":
                    correctAnswer = optionB;
                    break;

                case "C":
                    correctAnswer = optionC;
                    break;

                case "D":
                    correctAnswer = optionD;
                    break;

                default:
                    response.sendRedirect(
                        request.getContextPath() +
                        "/EditMissionServlet?id=" + id + "&error=1");
                    return;
            }

            int xpReward = Integer.parseInt(xpValue);

            if (xpReward < 1 || xpReward > 10000) {

                response.sendRedirect(
                    request.getContextPath() +
                    "/EditMissionServlet?id=" + id + "&error=1");
                return;
            }

            String sql =
                "UPDATE missions SET title=?, description=?, category=?, " +
                "difficulty=?, option_a=?, option_b=?, option_c=?, " +
                "option_d=?, correct_answer=?, xp_reward=? WHERE id=?";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setString(1, title);
                ps.setString(2, description);
                ps.setString(3, category);
                ps.setString(4, difficulty);

                ps.setString(5, optionA);
                ps.setString(6, optionB);
                ps.setString(7, optionC);
                ps.setString(8, optionD);

                ps.setString(9, correctAnswer);
                ps.setInt(10, xpReward);
                ps.setInt(11, id);

                int result = ps.executeUpdate();

                if (result == 1) {

                    response.sendRedirect(
                        request.getContextPath() +
                        "/manage-missions.jsp?updated=1");

                } else {

                    response.sendRedirect(
                        request.getContextPath() +
                        "/manage-missions.jsp?error=notfound");
                }
            }

        } catch (NumberFormatException e) {

            response.sendRedirect(
                request.getContextPath() +
                "/manage-missions.jsp?error=invalid");

        } catch (Exception e) {

            getServletContext().log("Error updating mission", e);

            response.sendRedirect(
                request.getContextPath() +
                "/manage-missions.jsp?error=1");
        }
    }
}
