
package com.codeaura.db;

import java.sql.Connection;

public class DBConnectionTest {

    public static void main(String[] args) {

        try {
            Connection con = DBConnection.getConnection();

            if (con != null && !con.isClosed()) {
                System.out.println("================================");
                System.out.println("   CODEAURA DATABASE CONNECTED");
                System.out.println("================================");
                System.out.println("Database: charantej");
                System.out.println("JDBC Connection: SUCCESS");
            }

            con.close();

        } catch (Exception e) {
            System.out.println("DATABASE CONNECTION FAILED!");
            e.printStackTrace();
        }
    }
}
