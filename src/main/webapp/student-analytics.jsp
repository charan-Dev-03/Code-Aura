
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*,java.util.*" %>
<%@ page import="com.codeaura.db.DBConnection" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private int percentage(int value, int total) {
        if (total <= 0) return 0;
        return (int) Math.round((value * 100.0) / total);
    }
%>

<%
if (!Boolean.TRUE.equals(session.getAttribute("adminLoggedIn"))) {
    response.sendRedirect("admin-login.jsp");
    return;
}

int totalStudents = 0;
int activeStudents = 0;
int inactiveStudents = 0;
int totalMissions = 0;
int totalSubmissions = 0;
int correctSubmissions = 0;
int incorrectSubmissions = 0;
int completedMissions = 0;
long totalXP = 0;

boolean databaseError = false;

List<Map<String, Object>> topStudents = new ArrayList<>();
List<Map<String, Object>> categoryStats = new ArrayList<>();
List<Map<String, Object>> levelStats = new ArrayList<>();

try (Connection con = DBConnection.getConnection()) {

    if (con == null) {
        throw new Exception("Database connection failed.");
    }

    // TOTAL STUDENTS

    String studentSql =
        "SELECT COUNT(*), " +
        "SUM(CASE WHEN account_status='ACTIVE' THEN 1 ELSE 0 END), " +
        "SUM(CASE WHEN account_status='INACTIVE' THEN 1 ELSE 0 END), " +
        "COALESCE(SUM(total_xp),0) FROM users";

    try (PreparedStatement ps = con.prepareStatement(studentSql);
         ResultSet rs = ps.executeQuery()) {

        if (rs.next()) {
            totalStudents = rs.getInt(1);
            activeStudents = rs.getInt(2);
            inactiveStudents = rs.getInt(3);
            totalXP = rs.getLong(4);
        }
    }

    // TOTAL MISSIONS

    try (PreparedStatement ps =
            con.prepareStatement("SELECT COUNT(*) FROM missions");
         ResultSet rs = ps.executeQuery()) {

        if (rs.next()) {
            totalMissions = rs.getInt(1);
        }
    }

    // SUBMISSION STATISTICS

    String submissionSql =
        "SELECT COUNT(*), " +
        "COALESCE(SUM(CASE WHEN is_correct=1 THEN 1 ELSE 0 END),0), " +
        "COALESCE(SUM(CASE WHEN is_correct=0 THEN 1 ELSE 0 END),0) " +
        "FROM mission_submissions";

    try (PreparedStatement ps =
            con.prepareStatement(submissionSql);
         ResultSet rs = ps.executeQuery()) {

        if (rs.next()) {
            totalSubmissions = rs.getInt(1);
            correctSubmissions = rs.getInt(2);
            incorrectSubmissions = rs.getInt(3);
        }
    }

    // DISTINCT COMPLETED MISSIONS

    String completedSql =
        "SELECT COUNT(*) FROM (" +
        "SELECT DISTINCT user_id, mission_id " +
        "FROM mission_submissions WHERE is_correct=1" +
        ") AS completed";

    try (PreparedStatement ps =
            con.prepareStatement(completedSql);
         ResultSet rs = ps.executeQuery()) {

        if (rs.next()) {
            completedMissions = rs.getInt(1);
        }
    }

    // TOP PERFORMING STUDENTS

    String topSql =
        "SELECT id, username, total_xp, player_level, account_status " +
        "FROM users ORDER BY total_xp DESC, player_level DESC, username ASC " +
        "LIMIT 10";

    try (PreparedStatement ps =
            con.prepareStatement(topSql);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {

            Map<String, Object> student = new HashMap<>();

            student.put("id", rs.getInt("id"));
            student.put("username", rs.getString("username"));
            student.put("xp", rs.getInt("total_xp"));
            student.put("level", rs.getInt("player_level"));
            student.put("status", rs.getString("account_status"));

            topStudents.add(student);
        }
    }

    // STUDENT LEVEL DISTRIBUTION

    String levelSql =
        "SELECT player_level, COUNT(*) AS student_count " +
        "FROM users GROUP BY player_level ORDER BY player_level";

    try (PreparedStatement ps =
            con.prepareStatement(levelSql);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {

            Map<String, Object> item = new HashMap<>();

            item.put("level", rs.getInt("player_level"));
            item.put("count", rs.getInt("student_count"));

            levelStats.add(item);
        }
    }

    // CATEGORY PERFORMANCE

    String categorySql =
        "SELECT m.category, COUNT(*) AS attempts, " +
        "SUM(CASE WHEN ms.is_correct=1 THEN 1 ELSE 0 END) AS correct " +
        "FROM mission_submissions ms " +
        "JOIN missions m ON ms.mission_id=m.id " +
        "GROUP BY m.category ORDER BY m.category";

    try (PreparedStatement ps =
            con.prepareStatement(categorySql);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {

            Map<String, Object> item = new HashMap<>();

            item.put("category", rs.getString("category"));
            item.put("attempts", rs.getInt("attempts"));
            item.put("correct", rs.getInt("correct"));

            categoryStats.add(item);
        }
    }

} catch (Exception e) {

    application.log("Student analytics database error", e);
    databaseError = true;
}

int successRate = percentage(correctSubmissions, totalSubmissions);
int activeRate = percentage(activeStudents, totalStudents);
int maxLevelCount = 1;

for (Map<String, Object> item : levelStats) {
    int count = (Integer) item.get("count");
    if (count > maxLevelCount) maxLevelCount = count;
}
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Student Analytics | CodeAura</title>

<style>

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    padding: 25px;
    font-family: Arial, sans-serif;
    background: #0b1020;
    color: #f8fafc;
}

.container {
    max-width: 1250px;
    margin: auto;
}

.header {
    margin-bottom: 30px;
}

.header h1 {
    color: #b69aff;
    font-size: 32px;
}

.header p {
    color: #94a3b8;
}

.back {
    color: #b69aff;
    text-decoration: none;
    display: inline-block;
    margin-top: 12px;
}

.section-title {
    margin: 35px 0 20px;
    font-size: 23px;
}

.stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 18px;
}

.stat-card {
    background: #171f35;
    padding: 23px;
    border: 1px solid #343d60;
    border-radius: 15px;
    transition: 0.3s;
}

.stat-card:hover {
    transform: translateY(-4px);
    border-color: #a78bfa;
}

.stat-icon {
    font-size: 30px;
}

.stat-card h2 {
    font-size: 30px;
    color: #b69aff;
    margin: 13px 0 8px;
}

.stat-card p {
    color: #a7b4ca;
    margin: 0;
}

.panels {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 22px;
    margin-top: 25px;
}

.panel {
    background: #171f35;
    border: 1px solid #343d60;
    border-radius: 15px;
    padding: 23px;
    min-width: 0;
}

.panel h3 {
    margin-top: 0;
    color: #d8caff;
}

.metric {
    margin: 22px 0;
}

.metric-label {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    margin-bottom: 9px;
    color: #cbd5e1;
}

.track {
    height: 12px;
    background: #303951;
    border-radius: 20px;
    overflow: hidden;
}

.fill {
    height: 100%;
    background: #9b7af2;
    border-radius: 20px;
}

.green {
    background: #35c98b;
}

.red {
    background: #ed667b;
}

.blue {
    background: #49a9ee;
}

.purple {
    background: #a78bfa;
}

.table-wrapper {
    overflow-x: auto;
}

table {
    width: 100%;
    min-width: 550px;
    border-collapse: collapse;
    margin-top: 15px;
}

th, td {
    padding: 14px;
    text-align: left;
    border-bottom: 1px solid #343d60;
}

th {
    color: #b69aff;
}

td {
    color: #d5dced;
}

.status {
    color: #58dfa0;
    font-weight: bold;
}

.empty {
    color: #94a3b8;
    padding: 20px 0;
}

.error {
    background: #4b202c;
    color: #ffb3bf;
    border-radius: 10px;
    padding: 15px;
    margin: 20px 0;
}

.footer {
    margin-top: 40px;
    padding: 20px;
    text-align: center;
    color: #718096;
}

@media(max-width: 950px) {
    .stats {
        grid-template-columns: repeat(2, 1fr);
    }
}

@media(max-width: 650px) {
    body {
        padding: 14px;
    }

    .stats,
    .panels {
        grid-template-columns: 1fr;
    }

    .header h1 {
        font-size: 26px;
    }
}

</style>

</head>

<body>

<div class="container">

    <div class="header">

        <h1>📊 Student Analytics Dashboard</h1>

        <p>
            Monitor student performance, XP progress and
            programming mission activity.
        </p>

        <a href="admin-dashboard.jsp" class="back">
            ← Back to Admin Dashboard
        </a>

    </div>

    <% if (databaseError) { %>

        <div class="error">
            Unable to load some analytics data.
            Please check your database connection and try again.
        </div>

    <% } %>


    <!-- OVERVIEW STATISTICS -->

    <h2 class="section-title">Platform Overview</h2>

    <div class="stats">

        <div class="stat-card">
            <div class="stat-icon">👨‍🎓</div>
            <h2><%= totalStudents %></h2>
            <p>Total Students</p>
        </div>

        <div class="stat-card">
            <div class="stat-icon">🟢</div>
            <h2><%= activeStudents %></h2>
            <p>Active Students</p>
        </div>

        <div class="stat-card">
            <div class="stat-icon">🔴</div>
            <h2><%= inactiveStudents %></h2>
            <p>Inactive Students</p>
        </div>

        <div class="stat-card">
            <div class="stat-icon">🚀</div>
            <h2><%= totalMissions %></h2>
            <p>Total Missions</p>
        </div>

        <div class="stat-card">
            <div class="stat-icon">📝</div>
            <h2><%= totalSubmissions %></h2>
            <p>Total Submissions</p>
        </div>

        <div class="stat-card">
            <div class="stat-icon">✅</div>
            <h2><%= correctSubmissions %></h2>
            <p>Correct Submissions</p>
        </div>

        <div class="stat-card">
            <div class="stat-icon">❌</div>
            <h2><%= incorrectSubmissions %></h2>
            <p>Incorrect Submissions</p>
        </div>

        <div class="stat-card">
            <div class="stat-icon">🏆</div>
            <h2><%= totalXP %></h2>
            <p>Total Student XP</p>
        </div>

    </div>


    <!-- PERFORMANCE PANELS -->

    <h2 class="section-title">Performance Analysis</h2>

    <div class="panels">

        <!-- STUDENT STATUS -->

        <div class="panel">

            <h3>👥 Student Account Status</h3>

            <div class="metric">

                <div class="metric-label">
                    <span>Active Students</span>
                    <strong><%= activeStudents %></strong>
                </div>

                <div class="track">
                    <div class="fill green"
                         style="width:<%= activeRate %>%"></div>
                </div>

                <p><%= activeRate %>% of registered students</p>

            </div>

            <div class="metric">

                <div class="metric-label">
                    <span>Inactive Students</span>
                    <strong><%= inactiveStudents %></strong>
                </div>

                <div class="track">
                    <div class="fill red"
                         style="width:<%= percentage(inactiveStudents,totalStudents) %>%"></div>
                </div>

                <p><%= percentage(inactiveStudents,totalStudents) %>% of registered students</p>

            </div>

        </div>


        <!-- SUBMISSION PERFORMANCE -->

        <div class="panel">

            <h3>📝 Submission Performance</h3>

            <div class="metric">

                <div class="metric-label">
                    <span>Correct Submissions</span>
                    <strong><%= correctSubmissions %></strong>
                </div>

                <div class="track">
                    <div class="fill green"
                         style="width:<%= successRate %>%"></div>
                </div>

            </div>

            <div class="metric">

                <div class="metric-label">
                    <span>Incorrect Submissions</span>
                    <strong><%= incorrectSubmissions %></strong>
                </div>

                <div class="track">
                    <div class="fill red"
                         style="width:<%= percentage(incorrectSubmissions,totalSubmissions) %>%"></div>
                </div>

            </div>

            <h2><%= successRate %>%</h2>
            <p>Overall correct submission rate</p>

        </div>


        <!-- LEVEL DISTRIBUTION -->

        <div class="panel">

            <h3>🎮 Student Level Distribution</h3>

            <% if (levelStats.isEmpty()) { %>

                <p class="empty">No student level data available.</p>

            <% } else { %>

                <% for (Map<String,Object> item : levelStats) {

                    int level = (Integer) item.get("level");
                    int count = (Integer) item.get("count");

                    int width = percentage(count,maxLevelCount);
                %>

                    <div class="metric">

                        <div class="metric-label">
                            <span>Level <%= level %></span>
                            <strong><%= count %> students</strong>
                        </div>

                        <div class="track">
                            <div class="fill purple"
                                 style="width:<%= width %>%"></div>
                        </div>

                    </div>

                <% } %>

            <% } %>

        </div>


        <!-- MISSION CATEGORY -->

        <div class="panel">

            <h3>💻 Mission Category Performance</h3>

            <% if (categoryStats.isEmpty()) { %>

                <p class="empty">
                    No mission submission data available.
                </p>

            <% } else { %>

                <% for (Map<String,Object> item : categoryStats) {

                    String category = (String) item.get("category");
                    int attempts = (Integer) item.get("attempts");
                    int correct = (Integer) item.get("correct");

                    int rate = percentage(correct,attempts);
                %>

                    <div class="metric">

                        <div class="metric-label">
                            <span><%= escapeHtml(category) %></span>
                            <strong><%= rate %>% correct</strong>
                        </div>

                        <div class="track">
                            <div class="fill blue"
                                 style="width:<%= rate %>%"></div>
                        </div>

                        <p><%= attempts %> attempts</p>

                    </div>

                <% } %>

            <% } %>

        </div>

    </div>


    <!-- COMPLETION STATISTICS -->

    <h2 class="section-title">Mission Completion Overview</h2>

    <div class="panel">

        <h3>🏅 Completed Student-Mission Combinations</h3>

        <h2 style="font-size:38px;color:#a78bfa;">
            <%= completedMissions %>
        </h2>

        <p style="color:#94a3b8;">
            Number of distinct student-mission pairs with
            at least one correct answer.
        </p>

    </div>


    <!-- TOP STUDENTS -->

    <h2 class="section-title">🏆 Top Performing Students</h2>

    <div class="panel">

        <div class="table-wrapper">

            <table>

                <tr>
                    <th>Rank</th>
                    <th>Student ID</th>
                    <th>Username</th>
                    <th>Total XP</th>
                    <th>Level</th>
                    <th>Status</th>
                </tr>

                <% if (topStudents.isEmpty()) { %>

                    <tr>
                        <td colspan="6">No student records found.</td>
                    </tr>

                <% } else {

                    int rank = 1;

                    for (Map<String,Object> student : topStudents) {
                %>

                    <tr>

                        <td>
                            <%= rank == 1 ? "🥇" :
                                rank == 2 ? "🥈" :
                                rank == 3 ? "🥉" : rank %>
                        </td>

                        <td><%= student.get("id") %></td>

                        <td>
                            <%= escapeHtml((String)student.get("username")) %>
                        </td>

                        <td><%= student.get("xp") %> XP</td>

                        <td>Level <%= student.get("level") %></td>

                        <td class="status">
                            <%= escapeHtml((String)student.get("status")) %>
                        </td>

                    </tr>

                <%
                        rank++;
                    }
                }
                %>

            </table>

        </div>

    </div>


    <div class="footer">
        CodeAura Student Analytics Dashboard | Think. Code. Conquer.
    </div>

</div>

</body>
</html>
