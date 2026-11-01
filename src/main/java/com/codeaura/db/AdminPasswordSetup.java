
package com.codeaura.db;

import java.security.SecureRandom;
import java.security.spec.KeySpec;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Base64;
import java.util.Scanner;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class AdminPasswordSetup {

    public static void main(String[] args) {

        try (Scanner scanner = new Scanner(System.in)) {

            System.out.print("Enter new admin password: ");
            String password = scanner.nextLine();

            if (password.length() < 8) {
                System.out.println("Password must be at least 8 characters.");
                return;
            }

            byte[] salt = new byte[16];
            new SecureRandom().nextBytes(salt);

            KeySpec spec = new PBEKeySpec(
                password.toCharArray(),
                salt,
                65536,
                256
            );

            SecretKeyFactory factory =
                SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");

            byte[] hash = factory.generateSecret(spec).getEncoded();

            String securePassword =
                "65536:" +
                Base64.getEncoder().encodeToString(salt) +
                ":" +
                Base64.getEncoder().encodeToString(hash);

            try (Connection con = DBConnection.getConnection()) {

                String sql =
                    "UPDATE admins SET password=? WHERE username=?";

                try (PreparedStatement ps = con.prepareStatement(sql)) {

                    ps.setString(1, securePassword);
                    ps.setString(2, "admin");

                    int updated = ps.executeUpdate();

                    if (updated == 1) {
                        System.out.println(
                            "ADMIN PASSWORD SECURED SUCCESSFULLY!"
                        );
                    } else {
                        System.out.println("Admin account not found.");
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
