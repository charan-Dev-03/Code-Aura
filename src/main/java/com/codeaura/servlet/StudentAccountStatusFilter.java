
package com.codeaura.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.codeaura.db.DBConnection;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter("/dashboard.jsp")
public class StudentAccountStatusFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig)
            throws ServletException {
    }

    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);

        // CHECK STUDENT LOGIN

        if (session == null ||
            !Boolean.TRUE.equals(session.getAttribute("userLoggedIn"))) {

            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        Object userIdObject = session.getAttribute("userId");

        if (!(userIdObject instanceof Integer)) {

            session.invalidate();

            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int userId = (Integer) userIdObject;

        // CHECK ACCOUNT STATUS IN DATABASE

        String sql =
            "SELECT account_status FROM users WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    String accountStatus =
                        rs.getString("account_status");

                    if ("ACTIVE".equals(accountStatus)) {

                        // ALLOW STUDENT TO CONTINUE

                        chain.doFilter(request, response);
                        return;
                    }
                }
            }

        } catch (Exception e) {

        	req.getServletContext().log(
        		    "Error checking student account status", e
        		);

            res.sendError(
                HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                "Unable to verify your account. Please try again."
            );

            return;
        }

        // ACCOUNT INACTIVE OR STUDENT NOT FOUND

        session.invalidate();

        res.sendRedirect(
            req.getContextPath() +
            "/login.jsp?error=deactivated"
        );
    }



    @Override
    public void destroy() {
    }
}
