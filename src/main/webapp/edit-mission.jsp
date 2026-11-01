
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%!
    private String escape(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    if (!Boolean.TRUE.equals(session.getAttribute("adminLoggedIn"))) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    Integer missionId = (Integer) request.getAttribute("id");

    if (missionId == null) {
        response.sendRedirect("manage-missions.jsp");
        return;
    }

    String title = (String) request.getAttribute("title");
    String description = (String) request.getAttribute("description");
    String category = (String) request.getAttribute("category");
    String difficulty = (String) request.getAttribute("difficulty");

    String optionA = (String) request.getAttribute("option_a");
    String optionB = (String) request.getAttribute("option_b");
    String optionC = (String) request.getAttribute("option_c");
    String optionD = (String) request.getAttribute("option_d");

    String correctAnswer = (String) request.getAttribute("correct_answer");

    int xpReward = (Integer) request.getAttribute("xp_reward");

    boolean error = "1".equals(request.getParameter("error"));
%>

<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Edit Mission | CodeAura</title>

<link rel="stylesheet" href="css/style.css">

<style>
body {
    background: #0b1020;
    color: #f8fafc;
    font-family: Arial, sans-serif;
    margin: 0;
}

.page {
    max-width: 850px;
    margin: 50px auto;
    padding: 30px;
}

.form-card {
    background: #151c31;
    border: 1px solid #343b60;
    border-radius: 18px;
    padding: 35px;
}

h1 {
    color: #a78bfa;
    margin-bottom: 10px;
}

.subtitle {
    color: #94a3b8;
    margin-bottom: 30px;
}

.form-group {
    margin-bottom: 22px;
}

label {
    display: block;
    margin-bottom: 10px;
    font-weight: bold;
}

input, textarea, select {
    width: 100%;
    box-sizing: border-box;
    padding: 14px;
    border-radius: 9px;
    border: 1px solid #343b60;
    background: #0b1020;
    color: white;
    font-size: 15px;
}

textarea {
    min-height: 110px;
    resize: vertical;
}

input:focus, textarea:focus, select:focus {
    outline: 2px solid #8b5cf6;
}

.options-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 18px;
}

.correct-options {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
}

.correct-options label {
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: normal;
}

.correct-options input {
    width: auto;
}

.submit-btn {
    width: 100%;
    padding: 16px;
    border: none;
    border-radius: 10px;
    background: linear-gradient(90deg, #8b5cf6, #6d28d9);
    color: white;
    font-size: 17px;
    font-weight: bold;
    cursor: pointer;
}

.submit-btn:hover {
    opacity: 0.9;
}

.back-link {
    display: inline-block;
    color: #a78bfa;
    text-decoration: none;
    margin-bottom: 20px;
}

.message {
    padding: 15px;
    border-radius: 8px;
    margin-bottom: 20px;
    background: #451f2a;
    color: #fca5a5;
}

@media(max-width:600px) {
    .page {
        padding: 15px;
    }

    .form-card {
        padding: 20px;
    }

    .options-grid {
        grid-template-columns: 1fr;
    }
}
</style>

</head>

<body>

<div class="page">

<a href="manage-missions.jsp" class="back-link">
    ← Back to Mission Management
</a>

<div class="form-card">

<h1>✏️ Edit Mission</h1>

<p class="subtitle">
    Update the programming challenge for CodeAura students.
</p>

<% if (error) { %>
    <div class="message">
        Unable to update mission. Please check your details and try again.
    </div>
<% } %>

<form action="<%= request.getContextPath() %>/EditMissionServlet"
      method="post">

    <input type="hidden" name="id"
           value="<%= missionId %>">

    <div class="form-group">
        <label>Question Title</label>

        <input type="text"
               name="title"
               value="<%= escape(title) %>"
               maxlength="100"
               required>
    </div>

    <div class="form-group">
        <label>Question Description</label>

        <textarea name="description"
                  required><%= escape(description) %></textarea>
    </div>

    <div class="options-grid">

        <div class="form-group">
            <label>Category</label>

            <select name="category" required>

                <option value="Java"
                    <%= "Java".equals(category) ? "selected" : "" %>>
                    Java
                </option>

                <option value="SQL"
                    <%= "SQL".equals(category) ? "selected" : "" %>>
                    SQL
                </option>

                <option value="DSA"
                    <%= "DSA".equals(category) ? "selected" : "" %>>
                    DSA
                </option>

            </select>
        </div>

        <div class="form-group">
            <label>Difficulty</label>

            <select name="difficulty" required>

                <option value="Easy"
                    <%= "Easy".equals(difficulty) ? "selected" : "" %>>
                    Easy
                </option>

                <option value="Medium"
                    <%= "Medium".equals(difficulty) ? "selected" : "" %>>
                    Medium
                </option>

                <option value="Hard"
                    <%= "Hard".equals(difficulty) ? "selected" : "" %>>
                    Hard
                </option>

            </select>
        </div>

    </div>

    <h3>Answer Options</h3>

    <div class="options-grid">

        <div class="form-group">
            <label>Option A</label>
            <input type="text" name="option_a"
                   value="<%= escape(optionA) %>" required>
        </div>

        <div class="form-group">
            <label>Option B</label>
            <input type="text" name="option_b"
                   value="<%= escape(optionB) %>" required>
        </div>

        <div class="form-group">
            <label>Option C</label>
            <input type="text" name="option_c"
                   value="<%= escape(optionC) %>" required>
        </div>

        <div class="form-group">
            <label>Option D</label>
            <input type="text" name="option_d"
                   value="<%= escape(optionD) %>" required>
        </div>

    </div>

    <div class="form-group">

        <label>Correct Answer</label>

        <div class="correct-options">

            <label>
                <input type="radio" name="correct_answer"
                       value="A"
                       <%= correctAnswer != null &&
                           correctAnswer.equals(optionA) ? "checked" : "" %>
                       required>
                Option A
            </label>

            <label>
                <input type="radio" name="correct_answer"
                       value="B"
                       <%= correctAnswer != null &&
                           correctAnswer.equals(optionB) ? "checked" : "" %>>
                Option B
            </label>

            <label>
                <input type="radio" name="correct_answer"
                       value="C"
                       <%= correctAnswer != null &&
                           correctAnswer.equals(optionC) ? "checked" : "" %>>
                Option C
            </label>

            <label>
                <input type="radio" name="correct_answer"
                       value="D"
                       <%= correctAnswer != null &&
                           correctAnswer.equals(optionD) ? "checked" : "" %>>
                Option D
            </label>

        </div>
    </div>

    <div class="form-group">

        <label>XP Reward</label>

        <input type="number"
               name="xp_reward"
               value="<%= xpReward %>"
               min="1"
               max="10000"
               required>

    </div>

    <button type="submit" class="submit-btn">
        Update Mission →
    </button>

</form>

</div>
</div>

</body>
</html>
