package com.smartbus.filter;

import com.smartbus.entity.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // Always allow: login page, static resources
        if (path.startsWith("/users/login") || path.startsWith("/WEB-INF/")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        User loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;

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

        // DRIVER — own portal and tracking endpoints
        if ("DRIVER".equals(role) &&
                (path.startsWith("/driver/") || path.startsWith("/tracking/"))) {
            chain.doFilter(request, response);
            return;
        }

        // PASSENGER — own portal and read-only tracking
        if ("PASSENGER".equals(role) &&
                (path.startsWith("/passenger/") || path.startsWith("/tracking/view") || path.startsWith("/tracking/latest"))) {
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
