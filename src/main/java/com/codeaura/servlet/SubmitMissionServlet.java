
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

@WebServlet("/SubmitMissionServlet")
public class SubmitMissionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        // Check student login
        if (session == null ||
            !Boolean.TRUE.equals(session.getAttribute("userLoggedIn")) ||
            !(session.getAttribute("userId") instanceof Integer)) {

            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        // Read submitted values
        int missionId;
        String selectedChoice = request.getParameter("answer");

        try {
            missionId = Integer.parseInt(
                request.getParameter("missionId")
            );
        } catch (Exception e) {
            response.sendRedirect("missions.jsp?result=invalid");
            return;
        }

        if (missionId <= 0 ||
            selectedChoice == null ||
            !selectedChoice.matches("[ABCD]")) {

            response.sendRedirect("missions.jsp?result=invalid");
            return;
        }

        Connection con = null;

        try {
            con = DBConnection.getConnection();

            if (con == null) {
                throw new Exception("Database connection failed.");
            }

            con.setAutoCommit(false);

            // Get mission details
            String missionSql =
                "SELECT title, correct_answer, option_a, option_b, " +
                "option_c, option_d, xp_reward " +
                "FROM missions WHERE id = ?";

            String missionTitle;
            String correctAnswer;
            String submittedAnswer;
            int xpReward;

            try (PreparedStatement ps =
                    con.prepareStatement(missionSql)) {

                ps.setInt(1, missionId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (!rs.next()) {
                        con.rollback();
                        response.sendRedirect(
                            "missions.jsp?result=notfound"
                        );
                        return;
                    }

                    missionTitle = rs.getString("title");
                    correctAnswer = rs.getString("correct_answer");
                    xpReward = rs.getInt("xp_reward");

                    // Convert A/B/C/D into actual option text
                    switch (selectedChoice) {
                        case "A":
                            submittedAnswer = rs.getString("option_a");
                            break;

                        case "B":
                            submittedAnswer = rs.getString("option_b");
                            break;

                        case "C":
                            submittedAnswer = rs.getString("option_c");
                            break;

                        case "D":
                            submittedAnswer = rs.getString("option_d");
                            break;

                        default:
                            con.rollback();
                            response.sendRedirect(
                                "missions.jsp?result=invalid"
                            );
                            return;
                    }
                }
            }

            if (correctAnswer == null || submittedAnswer == null) {
                con.rollback();
                response.sendRedirect("missions.jsp?result=invalid");
                return;
            }

            boolean isCorrect =
                correctAnswer.trim().equalsIgnoreCase(
                    submittedAnswer.trim()
                );

            // Read student's previous XP
            int previousXP = 0;

            String previousXPSql =
                "SELECT total_xp FROM users WHERE id = ?";

            try (PreparedStatement ps =
                    con.prepareStatement(previousXPSql)) {

                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new Exception("Student account not found.");
                    }

                    previousXP = rs.getInt("total_xp");
                }
            }

            // Count previously completed missions
            int previousCompletedMissions = 0;

            String completedSql =
                "SELECT COUNT(DISTINCT mission_id) " +
                "FROM mission_submissions " +
                "WHERE user_id = ? AND is_correct = 1";

            try (PreparedStatement ps =
                    con.prepareStatement(completedSql)) {

                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        previousCompletedMissions = rs.getInt(1);
                    }
                }
            }

            // Check whether XP was already earned for this mission
            boolean alreadyEarnedXP = false;

            String previousSql =
                "SELECT id FROM mission_submissions " +
                "WHERE user_id = ? AND mission_id = ? " +
                "AND is_correct = 1 LIMIT 1";

            try (PreparedStatement ps =
                    con.prepareStatement(previousSql)) {

                ps.setInt(1, userId);
                ps.setInt(2, missionId);

                try (ResultSet rs = ps.executeQuery()) {
                    alreadyEarnedXP = rs.next();
                }
            }

            // Save this submission
            String insertSql =
                "INSERT INTO mission_submissions " +
                "(user_id, mission_id, answer, is_correct) " +
                "VALUES (?, ?, ?, ?)";

            try (PreparedStatement ps =
                    con.prepareStatement(insertSql)) {

                ps.setInt(1, userId);
                ps.setInt(2, missionId);
                ps.setString(3, submittedAnswer);
                ps.setBoolean(4, isCorrect);

                ps.executeUpdate();
            }

            boolean xpAwarded = false;

            // Award XP only once for each correctly completed mission
            if (isCorrect && !alreadyEarnedXP && xpReward > 0) {

                String updateSql =
                    "UPDATE users SET total_xp = total_xp + ? " +
                    "WHERE id = ?";

                try (PreparedStatement ps =
                        con.prepareStatement(updateSql)) {

                    ps.setInt(1, xpReward);
                    ps.setInt(2, userId);

                    int updated = ps.executeUpdate();

                    if (updated != 1) {
                        throw new Exception("Student account not found.");
                    }
                }

                xpAwarded = true;
            }

            // Read updated XP
            int updatedXP = 0;

            String xpSql =
                "SELECT total_xp FROM users WHERE id = ?";

            try (PreparedStatement ps =
                    con.prepareStatement(xpSql)) {

                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        updatedXP = rs.getInt("total_xp");
                    }
                }
            }

            // Calculate student level
            int updatedLevel = calculateLevel(updatedXP);
            int previousLevel = calculateLevel(previousXP);

            // Update student level
            String levelSql =
                "UPDATE users SET player_level = ? WHERE id = ?";

            try (PreparedStatement ps =
                    con.prepareStatement(levelSql)) {

                ps.setInt(1, updatedLevel);
                ps.setInt(2, userId);

                ps.executeUpdate();
            }

            // ------------------------------------------
            // AUTOMATIC NOTIFICATIONS
            // ------------------------------------------

            if (isCorrect && !alreadyEarnedXP) {

                // 1. XP reward notification
                if (xpAwarded) {

                    insertNotification(
                        con,
                        userId,
                        "XP Reward",
                        "Congratulations! You earned " +
                        xpReward + " XP for completing " +
                        missionTitle + ".",
                        "XP"
                    );
                }

                // 2. First mission achievement
                int updatedCompletedMissions =
                    previousCompletedMissions + 1;

                if (previousCompletedMissions < 1 &&
                    updatedCompletedMissions >= 1) {

                    insertNotification(
                        con,
                        userId,
                        "Achievement Unlocked",
                        "Congratulations! You unlocked the First Step badge.",
                        "ACHIEVEMENT"
                    );
                }

                // 3. XP milestone achievements
                checkXPAchievements(
                    con,
                    userId,
                    previousXP,
                    updatedXP
                );
            }

            // 4. Level-up notification
            if (updatedLevel > previousLevel) {

                insertNotification(
                    con,
                    userId,
                    "Level Up!",
                    "Congratulations! You reached Level " +
                    updatedLevel + ". Keep learning and earning XP!",
                    "LEVEL_UP"
                );
            }

            // Commit all database changes
            con.commit();

            // Update student session
            session.setAttribute("totalXP", updatedXP);
            session.setAttribute("playerLevel", updatedLevel);

            // Redirect with result information
            if (isCorrect && xpAwarded) {

                response.sendRedirect(
                    "missions.jsp?result=correct&xp=" + xpReward
                );

            } else if (isCorrect) {

                response.sendRedirect(
                    "missions.jsp?result=already"
                );

            } else {

                response.sendRedirect(
                    "missions.jsp?result=incorrect"
                );
            }

        } catch (Exception e) {

            if (con != null) {
                try {
                    con.rollback();
                } catch (Exception rollbackError) {
                    log("Submission rollback failed", rollbackError);
                }
            }

            log("Mission submission failed", e);

            response.sendRedirect(
                "missions.jsp?result=error"
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

    // Calculate student level from XP
    private int calculateLevel(int xp) {

        if (xp >= 1000) {
            return 5;
        } else if (xp >= 500) {
            return 4;
        } else if (xp >= 250) {
            return 3;
        } else if (xp >= 100) {
            return 2;
        } else {
            return 1;
        }
    }

    // Insert a notification into the database
    private void insertNotification(
            Connection con,
            int userId,
            String title,
            String message,
            String type) throws Exception {

        String sql =
            "INSERT INTO notifications " +
            "(user_id, title, message, notification_type) " +
            "VALUES (?, ?, ?, ?)";

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, title);
            ps.setString(3, message);
            ps.setString(4, type);

            ps.executeUpdate();
        }
    }

    // Check and notify newly unlocked XP achievements
    private void checkXPAchievements(
            Connection con,
            int userId,
            int previousXP,
            int updatedXP) throws Exception {

        if (previousXP < 100 && updatedXP >= 100) {

            insertNotification(
                con,
                userId,
                "Achievement Unlocked",
                "Congratulations! You unlocked the Code Beginner badge.",
                "ACHIEVEMENT"
            );
        }

        if (previousXP < 250 && updatedXP >= 250) {

            insertNotification(
                con,
                userId,
                "Achievement Unlocked",
                "Congratulations! You unlocked the Code Explorer badge.",
                "ACHIEVEMENT"
            );
        }

        if (previousXP < 500 && updatedXP >= 500) {

            insertNotification(
                con,
                userId,
                "Achievement Unlocked",
                "Congratulations! You unlocked the Code Master badge.",
                "ACHIEVEMENT"
            );
        }

        if (previousXP < 1000 && updatedXP >= 1000) {

            insertNotification(
                con,
                userId,
                "Achievement Unlocked",
                "Congratulations! You unlocked the Code Legend badge.",
                "ACHIEVEMENT"
            );
        }
    }
}
