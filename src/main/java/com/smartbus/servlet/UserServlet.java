package com.smartbus.servlet;

import com.smartbus.entity.Driver;
import com.smartbus.entity.Passenger;
import com.smartbus.entity.RememberMeToken;
import com.smartbus.entity.User;
import com.smartbus.util.InputValidator;
import com.smartbus.util.EmailUtil;
import com.smartbus.util.PasswordUtil;
import com.smartbus.service.RememberMeService;
import com.smartbus.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@WebServlet("/users/*")
public class UserServlet extends HttpServlet {

    private static final String COOKIE_NAME = "SMARTBUS_REMEMBER";
    private static final int    COOKIE_MAX_AGE = 60 * 60 * 24 * 30; // 30 days

    private final UserService       userDAO       = new UserService();
    private final RememberMeService rememberMeDAO = new RememberMeService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if (path == null) path = "/";

        // Public paths — no auth needed
        if ("/login".equals(path) || "/logout".equals(path) || "/register".equals(path) || "/verify-phone".equals(path)) {
            if ("/verify-phone".equals(path)) {
                verifyPhone(req, resp);
                return;
            }
            switch (path) {
                case "/login":
                    // Support ?msg= from redirects (e.g. password reset success)
                    String msg = req.getParameter("msg");
                    if (msg != null && !msg.isBlank()) {
                        req.setAttribute("success", msg);
                    }
                    req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                    return;
                case "/logout":
                    // Clear remember-me cookie and DB token
                    Cookie[] cookies = req.getCookies();
                    if (cookies != null) {
                        for (Cookie c : cookies) {
                            if (COOKIE_NAME.equals(c.getName())) {
                                rememberMeDAO.deleteByToken(c.getValue());
                                Cookie clear = new Cookie(COOKIE_NAME, "");
                                clear.setMaxAge(0);
                                clear.setPath("/");
                                clear.setHttpOnly(true);
                                resp.addCookie(clear);
                                break;
                            }
                        }
                    }
                    if (req.getSession(false) != null) req.getSession().invalidate();
                    resp.sendRedirect(req.getContextPath() + "/users/login");
                    return;
                case "/register":
                    // GET /users/register → show login page with register tab open
                    req.setAttribute("tab", "register");
                    req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                    return;
            }
        }

        // All other /users/* paths require ADMIN
        if (!isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only administrators can manage users.");
            return;
        }

        switch (path) {
            case "/list":
                listUsers(req, resp);
                break;
            case "/new":
                req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
                break;
            case "/edit":
                editUser(req, resp);
                break;
            case "/approve":
                approveUser(req, resp);
                break;
            case "/reject":
                rejectUser(req, resp);
                break;
            case "/delete":
                deleteUser(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/users/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if (path == null) path = "/";

        if ("/login".equals(path)) {
            loginUser(req, resp);
            return;
        }

        if ("/register".equals(path)) {
            registerPassenger(req, resp);
            return;
        }

        if ("/verify-phone".equals(path)) {
            verifyPhone(req, resp);
            return;
        }

        // All POST actions require ADMIN
        if (!isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only administrators can manage users.");
            return;
        }

        switch (path) {
            case "/save":
                saveUser(req, resp);
                break;
            case "/approve":
                approveUser(req, resp);
                break;
            case "/reject":
                rejectUser(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/users/list");
        }
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return false;
        User u = (User) session.getAttribute("loggedUser");
        return u != null && "ADMIN".equals(u.getRole());
    }

    private void listUsers(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String search = req.getParameter("search");
        List<User> users;
        if (search != null && !search.trim().isEmpty()) {
            users = userDAO.searchByName(search.trim());
        } else {
            users = userDAO.findAllActive();
        }
        req.setAttribute("users", users);
        req.setAttribute("pendingUsers", userDAO.findPending());
        req.getRequestDispatcher("/WEB-INF/views/users.jsp").forward(req, resp);
    }

    private void approveUser(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Long id = Long.parseLong(req.getParameter("id"));
        User u = userDAO.findById(id);
        if (u != null) {
            u.setStatus("ACTIVE");
            userDAO.save(u);
            final String toEmail = u.getEmail();
            final String toName  = u.getName();
            new Thread(() -> {
                try {
                    EmailUtil.sendApprovalEmail(toEmail, toName);
                } catch (Exception mailEx) {
                    System.err.println("[ApproveUser] Failed to send approval email to "
                            + toEmail + ": " + mailEx.getMessage());
                }
            }, "approve-email-" + id).start();
        }
        resp.sendRedirect(req.getContextPath() + "/users/list");
    }

    private void rejectUser(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Long id = Long.parseLong(req.getParameter("id"));
        User u = userDAO.findById(id);
        if (u != null) {
            final String toEmail = u.getEmail();
            final String toName  = u.getName();
            userDAO.delete(id);
            new Thread(() -> {
                try {
                    EmailUtil.sendRejectionEmail(toEmail, toName);
                } catch (Exception mailEx) {
                    System.err.println("[RejectUser] Failed to send rejection email to "
                            + toEmail + ": " + mailEx.getMessage());
                }
            }, "reject-email-" + id).start();
        } else {
            userDAO.delete(id);
        }
        resp.sendRedirect(req.getContextPath() + "/users/list");
    }

    private void deleteUser(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/users/list");
            return;
        }
        User target = userDAO.findById(Long.parseLong(idParam));
        // Prevent deleting own account or other admins
        User me = (User) req.getSession(false).getAttribute("loggedUser");
        if (target != null && !target.getUserId().equals(me.getUserId()) && !"ADMIN".equals(target.getRole())) {
            userDAO.delete(target.getUserId());
        }
        resp.sendRedirect(req.getContextPath() + "/users/list");
    }

    private void editUser(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Long id = Long.parseLong(req.getParameter("id"));
        User user = userDAO.findById(id);
        req.setAttribute("user", user);
        req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
    }

    private void saveUser(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idParam = req.getParameter("userId");
        String role    = req.getParameter("role");
        String name    = req.getParameter("name");
        String email   = req.getParameter("email");
        String pwd     = req.getParameter("password");

        // Basic validation
        if (name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Name and email are required.");
            req.setAttribute("user", idParam != null && !idParam.isEmpty() ? userDAO.findById(Long.parseLong(idParam)) : null);
            req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
            return;
        }

        try {
            if (idParam != null && !idParam.isEmpty()) {
                // Edit existing — update base fields only
                User user = userDAO.findById(Long.parseLong(idParam));
                if (user == null) {
                    resp.sendRedirect(req.getContextPath() + "/users/list");
                    return;
                }
                user.setName(name.trim());
                user.setEmail(email.trim());
                user.setRole(role);
                if (pwd != null && !pwd.trim().isEmpty()) {
                    user.setPassword(PasswordUtil.hash(pwd));
                }
                userDAO.save(user);
            } else {
                // New user — must have password
                if (pwd == null || pwd.trim().isEmpty()) {
                    req.setAttribute("error", "Password is required for new users.");
                    req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
                    return;
                }
                // Check for duplicate email
                if (userDAO.findByEmail(email.trim()) != null) {
                    req.setAttribute("error", "A user with that email address already exists.");
                    req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
                    return;
                }
                if ("DRIVER".equals(role)) {
                    Driver driver = new Driver();
                    driver.setName(name.trim());
                    driver.setEmail(email.trim());
                    driver.setPassword(PasswordUtil.hash(pwd));
                    String regNum = req.getParameter("registrationNumber");
                    if (regNum == null || regNum.trim().isEmpty()) {
                        regNum = "DRV-" + System.currentTimeMillis() % 100000L;
                    }
                    driver.setRegistrationNumber(regNum.trim().toUpperCase());
                    userDAO.save(driver);
                } else if ("PASSENGER".equals(role)) {
                    userDAO.save(new Passenger(name.trim(), email.trim(), PasswordUtil.hash(pwd)));
                } else {
                    userDAO.save(new User(name.trim(), email.trim(), PasswordUtil.hash(pwd), role));
                }
            }
        } catch (Exception ex) {
            String msg = ex.getMessage() != null && ex.getMessage().toLowerCase().contains("duplicate")
                    ? "A user with that email address (or licence number) already exists."
                    : "Could not save user: " + ex.getMessage();
            req.setAttribute("error", msg);
            req.setAttribute("user", idParam != null && !idParam.isEmpty() ? userDAO.findById(Long.parseLong(idParam)) : null);
            req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/users/list");
    }

    private void loginUser(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // reCAPTCHA verification (only enforced when RECAPTCHA_SECRET_KEY is set)
        String rcSecret = System.getenv("RECAPTCHA_SECRET_KEY");
        if (rcSecret != null && !rcSecret.isBlank()) {
            String captchaToken = req.getParameter("g-recaptcha-response");
            if (captchaToken == null || captchaToken.isBlank() || !verifyCaptcha(captchaToken, rcSecret)) {
                req.setAttribute("error", "Please complete the reCAPTCHA verification.");
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                return;
            }
        }

        String email = req.getParameter("email");
        String password = req.getParameter("password");

        User user;
        try {
            user = userDAO.authenticate(email, password);
        } catch (Exception dbEx) {
            java.util.logging.Logger.getLogger(UserServlet.class.getName())
                .log(java.util.logging.Level.SEVERE, "Database error during login", dbEx);
            req.setAttribute("error", "Service temporarily unavailable. Please try again in a moment.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        if (user != null) {
            if ("PENDING".equals(user.getStatus())) {
                req.setAttribute("error", "Your account is pending admin approval. You'll be notified once approved.");
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                return;
            }
            if ("PENDING_REMOVAL".equals(user.getStatus())) {
                req.setAttribute("error", "Your account has been removed by an administrator.");
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                return;
            }

            HttpSession session = req.getSession(true);
            session.setAttribute("loggedUser", user);

            // Issue persistent remember-me cookie (30 days)
            String token = UUID.randomUUID().toString().replace("-", "");
            rememberMeDAO.save(new RememberMeToken(token, user, LocalDateTime.now().plusDays(30)));
            Cookie rememberCookie = new Cookie(COOKIE_NAME, token);
            rememberCookie.setMaxAge(COOKIE_MAX_AGE);
            rememberCookie.setPath("/");
            rememberCookie.setHttpOnly(true);
            resp.addCookie(rememberCookie);

            String dest;
            if ("DRIVER".equals(user.getRole())) {
                dest = "/driver/dashboard";
            } else if ("PASSENGER".equals(user.getRole())) {
                dest = "/passenger/dashboard";
            } else {
                dest = "/dashboard";
            }
            resp.sendRedirect(req.getContextPath() + dest);
        } else {
            req.setAttribute("error", "Invalid email or password.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
        }
    }

    private boolean verifyCaptcha(String token, String secret) {
        try {
            java.net.URL url = new java.net.URL("https://www.google.com/recaptcha/api/siteverify");
            java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);
            String body = "secret=" + java.net.URLEncoder.encode(secret, "UTF-8")
                    + "&response=" + java.net.URLEncoder.encode(token, "UTF-8");
            try (java.io.OutputStream out = conn.getOutputStream()) {
                out.write(body.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            }
            try (java.io.InputStream in = conn.getInputStream()) {
                String json = new String(in.readAllBytes(), java.nio.charset.StandardCharsets.UTF_8);
                return json.contains("\"success\":true") || json.contains("\"success\": true");
            }
        } catch (Exception e) {
            return false;
        }
    }

    private void registerPassenger(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String name            = req.getParameter("name");
        String email           = req.getParameter("email");
        String password        = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String role            = req.getParameter("registerRole");
        String licenseNumber   = req.getParameter("licenseNumber");
        String phone           = req.getParameter("phone");

        if (role == null || (!"PASSENGER".equals(role) && !"DRIVER".equals(role))) {
            role = "PASSENGER";
        }

        // Basic validation
        if (InputValidator.anyBlank(name, email, password)
                || !InputValidator.isValidEmail(email)
                || !InputValidator.isValidPassword(password)
                || !InputValidator.isValidName(name)) {
            req.setAttribute("error", "Please fill in all fields correctly. Email must be valid and password at least 6 characters.");
            req.setAttribute("tab", "register");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Passwords do not match.");
            req.setAttribute("tab", "register");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        if ("DRIVER".equals(role) && (licenseNumber == null || licenseNumber.trim().isEmpty())) {
            req.setAttribute("error", "Please provide your driver license number.");
            req.setAttribute("tab", "register");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        // Normalise phone if provided
        String normalPhone = "";
        if (phone != null && !phone.trim().isEmpty()) {
            normalPhone = phone.trim().replaceAll("[\\s\\-()]", "");
            if (!normalPhone.startsWith("+")) {
                normalPhone = "+" + normalPhone;
            }
        }

        // Check email uniqueness
        if (userDAO.emailExists(email.trim())) {
            req.setAttribute("error", "An account with this email already exists. Please sign in.");
            req.setAttribute("tab", "register");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        // Create the account directly (no OTP required)
        String hashedPassword = PasswordUtil.hash(password);
        User newUser;
        if ("DRIVER".equals(role)) {
            String license = licenseNumber != null ? licenseNumber.trim().toUpperCase() : "";
            Driver d = new Driver(name.trim(), email.trim(), hashedPassword,
                    license.isEmpty() ? "DRV-" + System.currentTimeMillis() % 100000L : license);
            d.setStatus("PENDING");
            d.setPhoneNumber(normalPhone);
            newUser = d;
        } else {
            Passenger p = new Passenger(name.trim(), email.trim(), hashedPassword);
            p.setStatus("PENDING");
            p.setPhoneNumber(normalPhone);
            newUser = p;
        }
        userDAO.save(newUser);

        resp.sendRedirect(req.getContextPath() + "/users/login?msg="
                + java.net.URLEncoder.encode("Account created! An admin will review your request. Once approved, you'll receive a confirmation email.", "UTF-8"));
    }

    private void verifyPhone(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("reg_phone") == null) {
            resp.sendRedirect(req.getContextPath() + "/users/login");
            return;
        }

        if ("GET".equals(req.getMethod())) {
            req.getRequestDispatcher("/WEB-INF/views/verify-phone.jsp").forward(req, resp);
            return;
        }

        // POST — validate OTP from session
        String code          = req.getParameter("otp");
        String phone         = (String)        s.getAttribute("reg_phone");
        String expected      = (String)        s.getAttribute("reg_otp");
        LocalDateTime expiry = (LocalDateTime) s.getAttribute("reg_otp_expiry");

        if (code == null || code.isBlank() || !code.equals(expected)) {
            req.setAttribute("error", "Incorrect code. Please try again.");
            req.getRequestDispatcher("/WEB-INF/views/verify-phone.jsp").forward(req, resp);
            return;
        }
        if (expiry == null || LocalDateTime.now().isAfter(expiry)) {
            req.setAttribute("error", "Your code has expired. Please go back and register again.");
            req.getRequestDispatcher("/WEB-INF/views/verify-phone.jsp").forward(req, resp);
            return;
        }

        // Phone verified — create the account
        String regName    = (String) s.getAttribute("reg_name");
        String regEmail   = (String) s.getAttribute("reg_email");
        String regPassword= (String) s.getAttribute("reg_password");
        String regRole    = (String) s.getAttribute("reg_role");
        String regLicense = (String) s.getAttribute("reg_license");
        String regPhone   = phone;

        s.removeAttribute("reg_name");    s.removeAttribute("reg_email");
        s.removeAttribute("reg_password"); s.removeAttribute("reg_role");
        s.removeAttribute("reg_license"); s.removeAttribute("reg_phone");
        s.removeAttribute("reg_otp");     s.removeAttribute("reg_otp_expiry");

        User newUser;
        if ("DRIVER".equals(regRole)) {
            Driver d = new Driver(regName, regEmail, regPassword,
                    regLicense.isEmpty() ? "DRV-" + System.currentTimeMillis() % 100000L : regLicense);
            d.setStatus("PENDING");
            d.setPhoneNumber(regPhone);
            newUser = d;
        } else {
            Passenger p = new Passenger(regName, regEmail, regPassword);
            p.setStatus("PENDING");
            p.setPhoneNumber(regPhone);
            newUser = p;
        }
        userDAO.save(newUser);

        resp.sendRedirect(req.getContextPath() + "/users/login?msg="
                + java.net.URLEncoder.encode("Phone verified! An admin will review your request. Once approved, you'll receive a confirmation email.", "UTF-8"));
    }
}
