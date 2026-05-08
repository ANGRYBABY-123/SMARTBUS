package com.smartbus.servlet;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.smartbus.dao.RememberMeDAO;
import com.smartbus.dao.UserDAO;
import com.smartbus.entity.Passenger;
import com.smartbus.entity.RememberMeToken;
import com.smartbus.entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Google OAuth 2.0 Sign-In integration.
 *
 * Flow:
 *  GET /oauth/google/init      → redirect to Google consent screen
 *  GET /oauth/google/callback  → exchange code, resolve or create user, set session
 *
 * Required context-params in web.xml:
 *  google.client.id     – OAuth 2.0 Client ID from Google Cloud Console
 *  google.client.secret – OAuth 2.0 Client Secret from Google Cloud Console
 */
@WebServlet("/oauth/google/*")
public class GoogleAuthServlet extends HttpServlet {

    private static final String COOKIE_NAME   = "SMARTBUS_REMEMBER";
    private static final int    COOKIE_MAX_AGE = 60 * 60 * 24 * 30; // 30 days

    private static final String AUTH_URI     = "https://accounts.google.com/o/oauth2/v2/auth";
    private static final String TOKEN_URI    = "https://oauth2.googleapis.com/token";
    private static final String USERINFO_URI = "https://www.googleapis.com/oauth2/v3/userinfo";

    private final UserDAO       userDAO       = new UserDAO();
    private final RememberMeDAO rememberMeDAO = new RememberMeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if (path == null) path = "/";

        String clientId     = getServletContext().getInitParameter("google.client.id");
        String clientSecret = getServletContext().getInitParameter("google.client.secret");

        if (clientId == null || clientId.isBlank() || "YOUR_GOOGLE_CLIENT_ID".equals(clientId)) {
            req.setAttribute("error", "Google Sign-In is not configured on this server.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        if ("/init".equals(path)) {
            initiateOAuth(req, resp, clientId);
        } else if ("/callback".equals(path)) {
            handleCallback(req, resp, clientId, clientSecret);
        } else {
            resp.sendRedirect(req.getContextPath() + "/users/login");
        }
    }

    // ── Step 1: redirect to Google ──────────────────────────────────────────

    private void initiateOAuth(HttpServletRequest req, HttpServletResponse resp, String clientId)
            throws IOException {
        // CSRF state token stored in session
        String state = UUID.randomUUID().toString();
        // Remember whether the user came from the login tab or the register tab
        String action = "register".equals(req.getParameter("action")) ? "register" : "login";
        req.getSession(true).setAttribute("oauth_state", state);
        req.getSession(true).setAttribute("oauth_action", action);

        String redirectUri = buildRedirectUri(req);
        String authUrl = AUTH_URI
                + "?client_id="     + encode(clientId)
                + "&redirect_uri="  + encode(redirectUri)
                + "&response_type=code"
                + "&scope="         + encode("openid email profile")
                + "&state="         + encode(state)
                + "&access_type=online"
                + "&prompt=select_account";

        resp.sendRedirect(authUrl);
    }

    // ── Step 2: exchange code and create session ────────────────────────────

    private void handleCallback(HttpServletRequest req, HttpServletResponse resp,
                                String clientId, String clientSecret)
            throws IOException, ServletException {

        String code  = req.getParameter("code");
        String state = req.getParameter("state");
        String error = req.getParameter("error");

        // Validate CSRF state
        HttpSession existingSession = req.getSession(false);
        String savedState = (existingSession != null)
                ? (String) existingSession.getAttribute("oauth_state") : null;

        if (error != null || code == null || state == null || !state.equals(savedState)) {
            req.setAttribute("error", "Google Sign-In was cancelled or failed. Please try again.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }
        String oauthAction = (existingSession != null)
                ? (String) existingSession.getAttribute("oauth_action") : "login";
        if (oauthAction == null) oauthAction = "login";
        if (existingSession != null) {
            existingSession.removeAttribute("oauth_state");
            existingSession.removeAttribute("oauth_action");
        }

        try {
            // Exchange authorisation code for access token
            String redirectUri    = buildRedirectUri(req);
            String tokenResponse  = exchangeCodeForToken(code, redirectUri, clientId, clientSecret);
            JsonObject tokenJson  = JsonParser.parseString(tokenResponse).getAsJsonObject();

            if (tokenJson.has("error")) {
                throw new RuntimeException("Token exchange error: " + tokenJson.get("error").getAsString());
            }

            String accessToken = tokenJson.get("access_token").getAsString();

            // Fetch Google user info
            String     userInfoJson = getUserInfo(accessToken);
            JsonObject userInfo     = JsonParser.parseString(userInfoJson).getAsJsonObject();

            String googleId = userInfo.get("sub").getAsString();
            String email    = userInfo.get("email").getAsString();
            String name     = userInfo.has("name") ? userInfo.get("name").getAsString() : email;

            // Find existing account by Google ID, then fall back to email
            User user = userDAO.findByGoogleId(googleId);
            if (user == null) {
                user = userDAO.findByEmail(email);
            }

            if (user == null) {
                if ("register".equals(oauthAction)) {
                    // Register tab → create PENDING account awaiting admin approval
                    Passenger p = new Passenger(name, email, "GOOGLE:" + UUID.randomUUID());
                    p.setStatus("PENDING");
                    p.setGoogleId(googleId);
                    user = userDAO.save(p);
                } else {
                    // Login tab → no account found, tell them to register
                    req.setAttribute("error",
                            "No account found for " + email + ". "
                            + "Please register first, then wait for admin approval.");
                    req.setAttribute("tab", "register");
                    req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                    return;
                }
            } else if (user.getGoogleId() == null) {
                // Link Google ID to pre-existing account
                user.setGoogleId(googleId);
                user = userDAO.save(user);
            }

            if ("PENDING".equals(user.getStatus())) {
                req.setAttribute("error", "Your account is pending admin approval. You will be able to sign in once an admin reviews and approves your account.");
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                return;
            }

            // Create new session and store logged-in user
            HttpSession session = req.getSession(true);
            session.setAttribute("loggedUser", user);

            // Issue 30-day remember-me cookie
            String token = UUID.randomUUID().toString().replace("-", "");
            rememberMeDAO.save(new RememberMeToken(token, user, LocalDateTime.now().plusDays(30)));
            Cookie cookie = new Cookie(COOKIE_NAME, token);
            cookie.setMaxAge(COOKIE_MAX_AGE);
            cookie.setPath("/");
            cookie.setHttpOnly(true);
            resp.addCookie(cookie);

            String dest = switch (user.getRole()) {
                case "DRIVER"    -> "/driver/dashboard";
                case "PASSENGER" -> "/passenger/dashboard";
                default          -> "/dashboard";
            };
            resp.sendRedirect(req.getContextPath() + dest);

        } catch (Exception e) {
            req.setAttribute("error", "Google Sign-In could not be completed. Please try again.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
        }
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private String exchangeCodeForToken(String code, String redirectUri,
                                        String clientId, String clientSecret)
            throws IOException, InterruptedException {
        String body = "code="          + encode(code)
                    + "&client_id="    + encode(clientId)
                    + "&client_secret=" + encode(clientSecret)
                    + "&redirect_uri=" + encode(redirectUri)
                    + "&grant_type=authorization_code";

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(TOKEN_URI))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .build();

        return HttpClient.newHttpClient()
                         .send(request, HttpResponse.BodyHandlers.ofString())
                         .body();
    }

    private String getUserInfo(String accessToken) throws IOException, InterruptedException {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(USERINFO_URI))
                .header("Authorization", "Bearer " + accessToken)
                .GET()
                .build();

        return HttpClient.newHttpClient()
                         .send(request, HttpResponse.BodyHandlers.ofString())
                         .body();
    }

    private String buildRedirectUri(HttpServletRequest req) {
        // Honour reverse-proxy headers (Render, nginx, etc.) so the URI
        // presented to Google matches the public-facing HTTPS address.
        String scheme = req.getHeader("X-Forwarded-Proto");
        if (scheme == null || scheme.isBlank()) scheme = req.getScheme();
        // X-Forwarded-Host may carry "host:port" already
        String host = req.getHeader("X-Forwarded-Host");
        if (host == null || host.isBlank()) {
            int port = req.getServerPort();
            host = req.getServerName() + ((port == 80 || port == 443) ? "" : ":" + port);
        }
        return scheme + "://" + host + req.getContextPath() + "/oauth/google/callback";
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
