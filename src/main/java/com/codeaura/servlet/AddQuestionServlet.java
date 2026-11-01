
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

@WebServlet("/AddQuestionServlet")
public class AddQuestionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String contextPath = request.getContextPath();

        // 1. Check admin login
        HttpSession session = request.getSession(false);

        if (session == null ||
            !Boolean.TRUE.equals(session.getAttribute("adminLoggedIn"))) {

            response.sendRedirect(contextPath + "/admin-login.jsp");
            return;
        }

        Integer adminId = (Integer) session.getAttribute("adminId");

        if (adminId == null) {
            response.sendRedirect(contextPath + "/admin-login.jsp");
            return;
        }

        // 2. Get form data
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

        // 3. Validate form fields
        if (title == null || description == null ||
            category == null || difficulty == null ||
            optionA == null || optionB == null ||
            optionC == null || optionD == null ||
            correctChoice == null || xpValue == null) {

            response.sendRedirect(contextPath + "/add-question.jsp?error=1");
            return;
        }

        title = title.trim();
        description = description.trim();
        category = category.trim();
        difficulty = difficulty.trim();

        optionA = optionA.trim();
        optionB = optionB.trim();
        optionC = optionC.trim();
        optionD = optionD.trim();

        if (title.isEmpty() || description.isEmpty() ||
            category.isEmpty() || difficulty.isEmpty() ||
            optionA.isEmpty() || optionB.isEmpty() ||
            optionC.isEmpty() || optionD.isEmpty()) {

            response.sendRedirect(contextPath + "/add-question.jsp?error=1");
            return;
        }

        // 4. Get correct answer text
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
                response.sendRedirect(contextPath + "/add-question.jsp?error=1");
                return;
        }

        // 5. Insert mission into MySQL
        try {

            int xpReward = Integer.parseInt(xpValue);

            if (xpReward < 1 || xpReward > 10000) {
                response.sendRedirect(contextPath + "/add-question.jsp?error=1");
                return;
            }

            String sql =
                "INSERT INTO missions " +
                "(title, description, category, difficulty, " +
                "option_a, option_b, option_c, option_d, " +
                "correct_answer, xp_reward, created_by) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

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
                ps.setInt(11, adminId);

                int result = ps.executeUpdate();

                if (result == 1) {

                    response.sendRedirect(
                        contextPath + "/add-question.jsp?success=1"
                    );

                } else {

                    response.sendRedirect(
                        contextPath + "/add-question.jsp?error=1"
                    );
                }
            }

        } catch (NumberFormatException e) {

            response.sendRedirect(contextPath + "/add-question.jsp?error=1");

        } catch (Exception e) {

            getServletContext().log(
                "Error while creating mission", e
            );

            response.sendRedirect(contextPath + "/add-question.jsp?error=1");
        }
    }
}
