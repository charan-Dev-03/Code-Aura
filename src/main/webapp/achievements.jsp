
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.codeaura.db.DBConnection" %>

<%
    if (!Boolean.TRUE.equals(session.getAttribute("userLoggedIn"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int totalXP = 0;
    int completedMissions = 0;

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = DBConnection.getConnection();

        String sql =
            "SELECT u.total_xp, " +
            "COUNT(DISTINCT CASE WHEN ms.is_correct = 1 " +
            "THEN ms.mission_id END) AS completed_missions " +
            "FROM users u " +
            "LEFT JOIN mission_submissions ms ON u.id = ms.user_id " +
            "WHERE u.id = ? " +
            "GROUP BY u.id, u.total_xp";

        ps = con.prepareStatement(sql);
        ps.setInt(1, userId);

        rs = ps.executeQuery();

        if (rs.next()) {
            totalXP = rs.getInt("total_xp");
            completedMissions = rs.getInt("completed_missions");
        }

    } catch (Exception e) {
        application.log("Achievements loading error", e);
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (con != null) con.close(); } catch (Exception e) {}
    }

    String[] badgeNames = {
        "First Step",
        "Code Beginner",
        "Code Explorer",
        "Code Master",
        "Code Legend"
    };

    String[] descriptions = {
        "Complete your first programming mission.",
        "Earn 100 XP and start your coding journey.",
        "Earn 250 XP and explore more challenges.",
        "Earn 500 XP and prove your coding skills.",
        "Earn 1000 XP and become a CodeAura legend."
    };

    String[] badgeNumbers = {
        "01", "100", "250", "500", "1000"
    };

    int[] requirements = {1, 100, 250, 500, 1000};

    boolean[] unlocked = {
        completedMissions >= 1,
        totalXP >= 100,
        totalXP >= 250,
        totalXP >= 500,
        totalXP >= 1000
    };

    int unlockedCount = 0;

    for (boolean status : unlocked) {
        if (status) {
            unlockedCount++;
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>My Achievements | CodeAura</title>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        body {
            background: #100d20;
            color: white;
            padding: 30px;
        }

        .container {
            max-width: 1150px;
            margin: auto;
        }

        h1 {
            color: #c5a3ff;
            font-size: 34px;
            margin-bottom: 10px;
        }

        .subtitle {
            color: #aaa;
            margin-bottom: 30px;
            line-height: 1.6;
        }

        .summary {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 35px;
        }

        .summary-card {
            background: #211b35;
            padding: 25px;
            border: 1px solid #40345e;
            border-radius: 14px;
        }

        .summary-card h2 {
            color: #c5a3ff;
            font-size: 30px;
            margin-bottom: 8px;
        }

        .summary-card p {
            color: #aaa;
        }

        .section-title {
            color: #c5a3ff;
            margin-bottom: 20px;
        }

        .badge-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 22px;
        }

        .badge-card {
            background: #211b35;
            border: 1px solid #40345e;
            border-radius: 15px;
            padding: 30px 20px;
            text-align: center;
            transition: 0.3s;
        }

        .badge-card:hover {
            transform: translateY(-5px);
            border-color: #a78bfa;
        }

        .badge-card.locked {
            opacity: 0.5;
            filter: grayscale(1);
        }

        .badge-icon {
            width: 85px;
            height: 85px;
            margin: 0 auto 20px;
            border-radius: 50%;
            background: linear-gradient(135deg, #8b5cf6, #c084fc);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 25px;
            font-weight: bold;
            box-shadow: 0 0 25px rgba(139, 92, 246, 0.25);
        }

        .badge-card h3 {
            color: #d8c2ff;
            margin-bottom: 12px;
            font-size: 20px;
        }

        .badge-card p {
            color: #aaa;
            font-size: 14px;
            line-height: 1.6;
            min-height: 45px;
        }

        .requirement {
            color: #facc15;
            font-weight: bold;
            margin: 20px 0;
        }

        .status {
            display: inline-block;
            padding: 9px 17px;
            border-radius: 25px;
            font-size: 12px;
            font-weight: bold;
        }

        .unlocked-status {
            background: #14532d;
            color: #4ade80;
        }

        .locked-status {
            background: #3f3f46;
            color: #d4d4d8;
        }

        .back-btn {
            display: inline-block;
            margin-top: 32px;
            padding: 14px 25px;
            background: #8b5cf6;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            transition: 0.3s;
        }

        .back-btn:hover {
            background: #7c3aed;
            transform: translateY(-2px);
        }

        @media(max-width: 750px) {
            .badge-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .summary {
                grid-template-columns: 1fr;
            }
        }

        @media(max-width: 480px) {
            body {
                padding: 18px;
            }

            .badge-grid {
                grid-template-columns: 1fr;
            }

            h1 {
                font-size: 27px;
            }
        }

    </style>

</head>

<body>

<div class="container">

    <h1>My Achievements</h1>

    <p class="subtitle">
        Unlock badges by completing missions and earning XP.
        Keep learning and become a CodeAura champion!
    </p>

    <div class="summary">

        <div class="summary-card">
            <h2><%= totalXP %></h2>
            <p>Total XP Earned</p>
        </div>

        <div class="summary-card">
            <h2><%= completedMissions %></h2>
            <p>Completed Missions</p>
        </div>

        <div class="summary-card">
            <h2><%= unlockedCount %> / 5</h2>
            <p>Achievements Unlocked</p>
        </div>

    </div>

    <h2 class="section-title">Your Badges</h2>

    <div class="badge-grid">

        <% for (int i = 0; i < badgeNames.length; i++) { %>

            <div class="badge-card <%= unlocked[i] ? "" : "locked" %>">

                <div class="badge-icon">
                    <%= badgeNumbers[i] %>
                </div>

                <h3><%= badgeNames[i] %></h3>

                <p><%= descriptions[i] %></p>

                <div class="requirement">

                    <% if (i == 0) { %>
                        1 Mission Required
                    <% } else { %>
                        <%= requirements[i] %> XP Required
                    <% } %>

                </div>

                <% if (unlocked[i]) { %>

                    <span class="status unlocked-status">
                        UNLOCKED
                    </span>

                <% } else { %>

                    <span class="status locked-status">
                        LOCKED
                    </span>

                <% } %>

            </div>

        <% } %>

    </div>

    <a href="dashboard.jsp" class="back-btn">
        Back to Dashboard
    </a>

</div>

</body>
</html>
