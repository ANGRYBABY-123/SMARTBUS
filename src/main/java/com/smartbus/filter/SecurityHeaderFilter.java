package com.smartbus.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Adds security-hardening HTTP response headers to every response.
 * Addresses OWASP Top 10 A05 (Security Misconfiguration) and A03 (Injection via XSS).
 */
@WebFilter(filterName = "SecurityHeaderFilter", urlPatterns = "/*")
public class SecurityHeaderFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletResponse resp = (HttpServletResponse) response;

        // Prevent MIME-type sniffing
        resp.setHeader("X-Content-Type-Options", "nosniff");

        // Deny framing (clickjacking protection)
        resp.setHeader("X-Frame-Options", "DENY");

        // Legacy XSS filter (IE/Edge legacy)
        resp.setHeader("X-XSS-Protection", "1; mode=block");

        // Limit referrer information
        resp.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");

        // Restrict browser feature access
        resp.setHeader("Permissions-Policy", "geolocation=(self), camera=(), microphone=()");

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
