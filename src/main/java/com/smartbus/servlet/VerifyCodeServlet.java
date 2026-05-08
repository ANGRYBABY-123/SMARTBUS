package com.smartbus.servlet;

import com.smartbus.dao.PasswordResetTokenDAO;
import com.smartbus.entity.PasswordResetToken;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;

@WebServlet("/verify-code")
public class VerifyCodeServlet extends HttpServlet {

    private final PasswordResetTokenDAO tokenDAO = new PasswordResetTokenDAO();

    /** GET: show the 5-digit code entry form. */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/verify-code.jsp").forward(req, resp);
    }

    /** POST: validate the submitted 5-digit code. */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Assemble code from d1–d5
        StringBuilder code = new StringBuilder(5);
        for (int i = 1; i <= 5; i++) {
            String digit = req.getParameter("d" + i);
            if (digit == null || digit.isBlank()) {
                req.setAttribute("codeError", "Please enter all 5 digits of the code.");
                req.getRequestDispatcher("/WEB-INF/views/verify-code.jsp").forward(req, resp);
                return;
            }
            code.append(digit.trim());
        }

        PasswordResetToken prt = tokenDAO.findByToken(code.toString());

        if (prt == null) {
            req.setAttribute("codeError", "Incorrect code. Please check your email and try again.");
            req.getRequestDispatcher("/WEB-INF/views/verify-code.jsp").forward(req, resp);
            return;
        }

        if (LocalDateTime.now().isAfter(prt.getExpiry())) {
            try { tokenDAO.deleteByUserId(prt.getUserId()); } catch (Exception ignored) {}
            req.setAttribute("codeError", "This code has expired. Please request a new one.");
            req.getRequestDispatcher("/WEB-INF/views/verify-code.jsp").forward(req, resp);
            return;
        }

        // Code is valid — mark session as verified and redirect to reset page
        HttpSession session = req.getSession(true);
        session.setAttribute("resetUserId", prt.getUserId());

        resp.sendRedirect(req.getContextPath() + "/reset-password");
    }
}
