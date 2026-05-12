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

    /** GET: show the standalone forgot-password page. */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, resp);
    }

    /** POST: validate email, generate 5-digit code, send email, redirect to verify page. */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        if (email == null || email.isBlank()) {
            req.setAttribute("forgotError", "Please enter your email address.");
            req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, resp);
            return;
        }

        String normalised = email.trim().toLowerCase();

        try {
            User user = userDAO.findByEmail(normalised);

            if (user == null) {
                req.setAttribute("forgotError",
                        "No account found for \"" + normalised + "\". "
                        + "Please check the email you registered with.");
                req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, resp);
                return;
            }

            // Remove any existing code for this user
            tokenDAO.deleteByUserId(user.getUserId());

            // Generate a 5-digit code (zero-padded)
            String code = String.format("%05d", RANDOM.nextInt(100000));

            // Save with 15-minute expiry
            LocalDateTime expiry = LocalDateTime.now().plusMinutes(TOKEN_EXPIRY_MINUTES);
            tokenDAO.save(new PasswordResetToken(user.getUserId(), code, expiry));

            // Send code via email
            try {
                EmailUtil.sendPasswordResetCode(user.getEmail(), code);
            } catch (Exception mailEx) {
                getServletContext().log("[ForgotPassword] SMTP failure for " + normalised, mailEx);
                req.setAttribute("forgotError",
                        "Your account was found but the reset email could not be sent. "
                        + "Please try again in a moment.");
                req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, resp);
                return;
            }

            // Store email in session so the verify page can display it
            req.getSession(true).setAttribute("resetEmail", normalised);

        } catch (Exception ex) {
            getServletContext().log("ForgotPasswordServlet error", ex);
            req.setAttribute("forgotError", "An unexpected error occurred. Please try again.");
            req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/verify-code");
    }
}
