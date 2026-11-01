# CodeAura – Programming Learning Game

CodeAura is a web-based programming learning platform where students can practice programming questions, complete missions, earn XP, unlock achievements, and compete on a global leaderboard.

## Features

### Student Features
- Student registration, login, and logout
- Student dashboard and profile
- Programming missions in Java, SQL, and DSA
- Multiple-choice question evaluation
- XP rewards and level progression
- Achievements and badges
- Global leaderboard
- Learning history
- Notifications

### Admin Features
- Admin login and dashboard
- Add, edit, and delete missions
- View and manage students
- Activate and deactivate student accounts
- View mission submissions
- Send notifications to students
- Student analytics

## Technologies Used

- Frontend: HTML, CSS, JavaScript, JSP
- Backend: Java Servlets, JDBC
- Database: MySQL
- Server: Apache Tomcat 10.1
- IDE: Eclipse

## Database Setup

1. Install MySQL and MySQL Workbench.
2. Create the database:

   `CREATE DATABASE charantej;`

3. Create the required tables using your project's database SQL script.
4. Configure the database connection using the environment variables below.

## Database Environment Variables

Configure these environment variables on your computer:

- `MYSQL_URL` – JDBC database URL
- `MYSQL_USER` – MySQL username
- `MYSQL_PASSWORD` – MySQL password

Example URL:

`jdbc:mysql://localhost:3306/charantej`

Never publish your actual database password.

## Run the Project in Eclipse

1. Import the CodeAura project into Eclipse.
2. Add Apache Tomcat 10.1.
3. Add the MySQL Connector/J library.
4. Configure the database environment variables.
5. Start the Tomcat server.
6. Open the application in your browser.

## Project Purpose

CodeAura helps students improve their programming knowledge through interactive missions, progress tracking, achievements, and competition.

---

**Project Name:** CodeAura  
**Project Type:** Java Full Stack Web Application