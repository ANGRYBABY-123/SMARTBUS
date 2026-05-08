package com.smartbus.servlet;

import com.smartbus.dao.UserDAO;
import com.smartbus.entity.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Lightweight JSON endpoint used by the admin dashboard for live pending-count polling.
 * GET /api/pending-count  →  {"count": N}
 * Returns 403 if the requester is not an ADMIN.
 */
@WebServlet("/api/pending-count")
public class PendingCountServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        if (loggedUser == null || !"ADMIN".equals(loggedUser.getRole())) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.getWriter().write("{\"error\":\"forbidden\"}");
            return;
        }

        long count = userDAO.findPending().size();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write("{\"count\":" + count + "}");
    }
}
