package com.smartbus.servlet;

import com.smartbus.dao.PasswordResetTokenDAO;
import com.smartbus.dao.UserDAO;
import com.smartbus.entity.PasswordResetToken;
import com.smartbus.entity.User;
import com.smartbus.util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.SecureRandom;
import java.time.LocalDateTime;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private static final int TOKEN_EXPIRY_MINUTES = 15;
    private static final SecureRandom RANDOM = new SecureRandom();

    private final UserDAO userDAO = new UserDAO();
    private final PasswordResetTokenDAO tokenDAO = new PasswordResetTokenDAO();

    /** GET: redirect to login page (form is inline there). */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + "/users/login");
    }

    /**
     * POST: receive email, generate token, send reset email.
     * Always shows the same success message whether the email exists or not
     * to prevent user enumeration attacks.
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        if (email == null || email.isBlank()) {
            req.setAttribute("error", "Please enter your email address.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        // Always show the same message regardless of whether email exists
        final String successMsg = "If that email is registered, you'll receive a reset link shortly. "
                                + "Check your inbox (and spam folder).";

        try {
            User user = userDAO.findByEmail(email.trim().toLowerCase());
            if (user != null) {
                // Remove any existing token for this user
                tokenDAO.deleteByUserId(user.getUserId());

                // Generate a 64-char hex token (32 random bytes)
                byte[] bytes = new byte[32];
                RANDOM.nextBytes(bytes);
                StringBuilder sb = new StringBuilder(64);
                for (byte b : bytes) {
                    sb.append(String.format("%02x", b));
                }
                String token = sb.toString();

                // Save token with 15-minute expiry
                LocalDateTime expiry = LocalDateTime.now().plusMinutes(TOKEN_EXPIRY_MINUTES);
                tokenDAO.save(new PasswordResetToken(user.getUserId(), token, expiry));

                // Send reset email (non-blocking failure — don't reveal to user)
                try {
                    EmailUtil.sendPasswordReset(user.getEmail(), token);
                } catch (Exception mailEx) {
                    // Log but don't expose to user
                    getServletContext().log("Password reset email failed for: " + email, mailEx);
                }
            }
        } catch (Exception ex) {
            getServletContext().log("ForgotPasswordServlet error", ex);
        }

        req.setAttribute("success", successMsg);
        req.setAttribute("showForgot", true);
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }
}
