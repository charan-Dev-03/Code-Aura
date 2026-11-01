
package com.codeaura.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
        System.getenv("MYSQL_URL");

    private static final String USER =
        System.getenv("MYSQL_USER");

    private static final String PASSWORD =
        System.getenv("MYSQL_PASSWORD");

    public static Connection getConnection()
            throws SQLException {

        try {

            Class.forName("com.mysql.cj.jdbc.Driver");

            if (URL == null || USER == null || PASSWORD == null) {
                throw new SQLException(
                    "Database environment variables are missing."
                );
            }

            return DriverManager.getConnection(
                URL, USER, PASSWORD
            );

        } catch (ClassNotFoundException e) {

            throw new SQLException(
                "MySQL JDBC Driver not found!", e
            );
        }
    }
}
