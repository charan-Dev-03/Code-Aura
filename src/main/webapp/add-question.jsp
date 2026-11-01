<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%
    if (session.getAttribute("adminLoggedIn") == null ||
        !Boolean.TRUE.equals(session.getAttribute("adminLoggedIn"))) {
        response.sendRedirect("admin-login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Add Mission | CodeAura</title>

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
    background: linear-gradient(90deg,#8b5cf6,#6d28d9);
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

<a href="admin-dashboard.jsp" class="back-link">
    ← Back to Admin Dashboard
</a>

<div class="form-card">

<h1>🚀 Create New Mission</h1>

<p class="subtitle">
    Add a programming challenge for CodeAura students.
</p>
<% if ("1".equals(request.getParameter("success"))) { %>
    <div style="background:#123d30;color:#4ade80;
                padding:15px;border-radius:8px;margin-bottom:20px;">
        Mission created successfully! 
    </div>
<% } %>

<% if ("1".equals(request.getParameter("error"))) { %>
    <div style="background:#451f2a;color:#fca5a5;
                padding:15px;border-radius:8px;margin-bottom:20px;">
        Failed to create mission. Please check your details.
    </div>
<% } %>
<form action="<%= request.getContextPath() %>/AddQuestionServlet" method="post">

    <div class="form-group">
        <label>Question Title</label>
        <input type="text" name="title"
               placeholder="Enter question title"
               maxlength="100" required>
    </div>

    <div class="form-group">
        <label>Question Description</label>
        <textarea name="description"
                  placeholder="Explain the programming question..."
                  required></textarea>
    </div>

    <div class="options-grid">

        <div class="form-group">
            <label>Category</label>
            <select name="category" required>
                <option value="">Select Category</option>
                <option value="Java">Java</option>
                <option value="SQL">SQL</option>
                <option value="DSA">DSA</option>
            </select>
        </div>

        <div class="form-group">
            <label>Difficulty</label>
            <select name="difficulty" required>
                <option value="">Select Difficulty</option>
                <option value="Easy">Easy</option>
                <option value="Medium">Medium</option>
                <option value="Hard">Hard</option>
            </select>
        </div>

    </div>

    <h3>Answer Options</h3>

    <div class="options-grid">

        <div class="form-group">
            <label>Option A</label>
            <input type="text" name="option_a"
                   placeholder="Enter option A" required>
        </div>

        <div class="form-group">
            <label>Option B</label>
            <input type="text" name="option_b"
                   placeholder="Enter option B" required>
        </div>

        <div class="form-group">
            <label>Option C</label>
            <input type="text" name="option_c"
                   placeholder="Enter option C" required>
        </div>

        <div class="form-group">
            <label>Option D</label>
            <input type="text" name="option_d"
                   placeholder="Enter option D" required>
        </div>

    </div>

    <div class="form-group">
        <label>Correct Answer</label>

        <div class="correct-options">

            <label>
                <input type="radio" name="correct_answer"
                       value="A" required> Option A
            </label>

            <label>
                <input type="radio" name="correct_answer"
                       value="B"> Option B
            </label>

            <label>
                <input type="radio" name="correct_answer"
                       value="C"> Option C
            </label>

            <label>
                <input type="radio" name="correct_answer"
                       value="D"> Option D
            </label>

        </div>
    </div>

    <div class="form-group">
        <label>XP Reward</label>
        <input type="number" name="xp_reward"
               value="50" min="1" max="10000" required>
    </div>

    <button type="submit" class="submit-btn">
        Create Mission →
    </button>

</form>

</div>
</div>

</body>
</html>
