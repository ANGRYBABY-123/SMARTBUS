package com.smartbus.servlet;

import com.smartbus.dao.PasswordResetTokenDAO;
import com.smartbus.dao.UserDAO;
import com.smartbus.entity.PasswordResetToken;
import com.smartbus.entity.User;
import com.smartbus.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private final PasswordResetTokenDAO tokenDAO = new PasswordResetTokenDAO();
    private final UserDAO userDAO = new UserDAO();

    /** GET: validate token and show the reset form, or show an error. */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String token = req.getParameter("token");
        String error = validateToken(token);

        if (error != null) {
            req.setAttribute("tokenError", error);
        } else {
            req.setAttribute("token", token);
        }
        req.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(req, resp);
    }

    /** POST: verify token, update password, delete token. */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String token           = req.getParameter("token");
        String newPassword     = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        // Re-validate token on POST
        String error = validateToken(token);
        if (error != null) {
            req.setAttribute("tokenError", error);
            req.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(req, resp);
            return;
        }

        // Validate passwords
        if (newPassword == null || newPassword.length() < 6) {
            req.setAttribute("token", token);
            req.setAttribute("error", "Password must be at least 6 characters.");
            req.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(req, resp);
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("token", token);
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(req, resp);
            return;
        }

        try {
            PasswordResetToken prt = tokenDAO.findByToken(token);
            User user = userDAO.findById(prt.getUserId());

            if (user == null) {
                req.setAttribute("tokenError", "Account not found. Please contact support.");
                req.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(req, resp);
                return;
            }

            // Hash and save new password
            user.setPassword(PasswordUtil.hash(newPassword));
            userDAO.save(user);

            // Delete the used token
            tokenDAO.deleteByUserId(user.getUserId());

        } catch (Exception ex) {
            getServletContext().log("ResetPasswordServlet error", ex);
            req.setAttribute("token", token);
            req.setAttribute("error", "An unexpected error occurred. Please try again.");
            req.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(req, resp);
            return;
        }

        // Success — redirect to login
        resp.sendRedirect(req.getContextPath()
                + "/users/login?msg=Password+updated+successfully.+You+can+now+sign+in.");
    }

    /**
     * Returns null if valid, or an error message string if invalid/expired.
     */
    private String validateToken(String token) {
        if (token == null || token.isBlank()) {
            return "Invalid or missing reset link.";
        }
        PasswordResetToken prt = tokenDAO.findByToken(token);
        if (prt == null) {
            return "This reset link is invalid or has already been used.";
        }
        if (LocalDateTime.now().isAfter(prt.getExpiry())) {
            // Clean up expired token
            try { tokenDAO.deleteByUserId(prt.getUserId()); } catch (Exception ignored) {}
            return "This reset link has expired. Please request a new one.";
        }
        return null;
    }
}
