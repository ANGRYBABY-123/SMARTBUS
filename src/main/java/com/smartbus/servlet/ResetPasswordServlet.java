package com.smartbus.servlet;

import com.smartbus.entity.User;
import com.smartbus.util.PasswordUtil;
import com.smartbus.service.PasswordResetTokenService;
import com.smartbus.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private final PasswordResetTokenService tokenDAO = new PasswordResetTokenService();
    private final UserService userDAO = new UserService();

    /** GET: check session for a verified userId, show the form or an error. */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("resetUserId") : null;

        if (userId == null) {
            req.setAttribute("tokenError",
                    "Your session has expired or the code has not been verified. Please start over.");
        }
        req.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(req, resp);
    }

    /** POST: use session userId to update password, then clear session. */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("resetUserId") : null;

        if (userId == null) {
            req.setAttribute("tokenError", "Session expired. Please start over.");
            req.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(req, resp);
            return;
        }

        String newPassword     = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (newPassword == null || newPassword.length() < 8) {
            req.setAttribute("error", "Password must be at least 6 characters.");
            req.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(req, resp);
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(req, resp);
            return;
        }

        try {
            User user = userDAO.findById(userId);
            if (user == null) {
                req.setAttribute("tokenError", "Account not found. Please contact support.");
                req.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(req, resp);
                return;
            }

            user.setPassword(PasswordUtil.hash(newPassword));
            userDAO.save(user);
            tokenDAO.deleteByUserId(userId);

            // Clear session reset state
            session.removeAttribute("resetUserId");
            session.removeAttribute("resetEmail");

        } catch (Exception ex) {
            getServletContext().log("ResetPasswordServlet error", ex);
            req.setAttribute("error", "An unexpected error occurred. Please try again.");
            req.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath()
                + "/users/login?msg=Password+updated+successfully.+You+can+now+sign+in.");
    }
}

