package com.smartbus.filter;

import com.smartbus.dao.RememberMeDAO;
import com.smartbus.entity.RememberMeToken;
import com.smartbus.entity.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final String COOKIE_NAME = "SMARTBUS_REMEMBER";
    private final RememberMeDAO rememberMeDAO = new RememberMeDAO();

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // Always allow: login, register, Google OAuth flow, password reset, static resources
        if (path.startsWith("/users/login")
                || path.startsWith("/users/register")
                || path.startsWith("/oauth/google/")
                || path.startsWith("/forgot-password")
                || path.startsWith("/verify-code")
                || path.startsWith("/reset-password")
                || path.startsWith("/WEB-INF/")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        User loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        // No session — try remember-me cookie
        if (loggedUser == null) {
            Cookie[] cookies = req.getCookies();
            if (cookies != null) {
                for (Cookie c : cookies) {
                    if (COOKIE_NAME.equals(c.getName())) {
                        RememberMeToken rmt = rememberMeDAO.findByToken(c.getValue());
                        if (rmt != null) {
                            loggedUser = rmt.getUser();
                            HttpSession newSession = req.getSession(true);
                            newSession.setAttribute("loggedUser", loggedUser);
                        }
                        break;
                    }
                }
            }
        }

        // Not logged in — redirect to login
        if (loggedUser == null) {
            resp.sendRedirect(req.getContextPath() + "/users/login");
            return;
        }

        String role = loggedUser.getRole();

        // ADMIN — full access
        if ("ADMIN".equals(role)) {
            chain.doFilter(request, response);
            return;
        }

        // DRIVER — own portal, tracking, notifications and AI assistant
        if ("DRIVER".equals(role) &&
                (path.startsWith("/driver/") || path.startsWith("/tracking/")
                 || path.startsWith("/notifications/") || path.startsWith("/api/")
                 || path.startsWith("/ai/"))) {
            chain.doFilter(request, response);
            return;
        }

        // PASSENGER — own portal, read-only tracking, notifications and AI assistant
        if ("PASSENGER".equals(role) &&
                (path.startsWith("/passenger/") || path.startsWith("/tracking/view")
                 || path.startsWith("/tracking/latest") || path.startsWith("/notifications/")
                 || path.startsWith("/api/") || path.startsWith("/ai/"))) {
            chain.doFilter(request, response);
            return;
        }

        // Logout always allowed
        if (path.startsWith("/users/logout")) {
            chain.doFilter(request, response);
            return;
        }

        // All other paths — deny
        resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
        req.setAttribute("message", "Access denied. You do not have permission to view this page.");
        req.getRequestDispatcher("/WEB-INF/views/error500.jsp").forward(req, resp);
    }

    @Override
    public void destroy() {}
}
