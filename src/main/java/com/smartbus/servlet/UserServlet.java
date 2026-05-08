package com.smartbus.servlet;

import com.smartbus.dao.RememberMeDAO;
import com.smartbus.dao.UserDAO;
import com.smartbus.entity.Driver;
import com.smartbus.entity.Passenger;
import com.smartbus.entity.RememberMeToken;
import com.smartbus.entity.User;
import com.smartbus.util.InputValidator;
import com.smartbus.util.PasswordUtil;
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

    private final UserDAO       userDAO       = new UserDAO();
    private final RememberMeDAO rememberMeDAO = new RememberMeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if (path == null) path = "/";

        // Public paths — no auth needed
        if ("/login".equals(path) || "/logout".equals(path) || "/register".equals(path)) {
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
            case "/delete":
                deleteUser(req, resp);
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
            users = userDAO.findAll();
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
        }
        resp.sendRedirect(req.getContextPath() + "/users/list");
    }

    private void rejectUser(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Long id = Long.parseLong(req.getParameter("id"));
        userDAO.delete(id);
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

        if (idParam != null && !idParam.isEmpty()) {
            // Edit existing — update base fields only
            User user = userDAO.findById(Long.parseLong(idParam));
            user.setName(name);
            user.setEmail(email);
            user.setRole(role);
            if (pwd != null && !pwd.trim().isEmpty()) {
                user.setPassword(PasswordUtil.hash(pwd));
            }
            userDAO.save(user);
        } else {
            // New user — persist the correct JPA subtype
            if ("DRIVER".equals(role)) {
                Driver driver = new Driver();
                driver.setName(name);
                driver.setEmail(email);
                driver.setPassword(PasswordUtil.hash(pwd));
                String regNum = req.getParameter("registrationNumber");
                if (regNum == null || regNum.trim().isEmpty()) {
                    regNum = "DRV-" + System.currentTimeMillis() % 100000L;
                }
                driver.setRegistrationNumber(regNum.trim().toUpperCase());
                userDAO.save(driver);
            } else if ("PASSENGER".equals(role)) {
                userDAO.save(new Passenger(name, email, PasswordUtil.hash(pwd)));
            } else {
                userDAO.save(new User(name, email, PasswordUtil.hash(pwd), role));
            }
        }
        resp.sendRedirect(req.getContextPath() + "/users/list");
    }

    private void deleteUser(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Long id = Long.parseLong(req.getParameter("id"));
        // Prevent admin from deleting themselves
        HttpSession session = req.getSession(false);
        if (session != null) {
            User loggedUser = (User) session.getAttribute("loggedUser");
            if (loggedUser != null && loggedUser.getUserId().equals(id)) {
                resp.sendRedirect(req.getContextPath() + "/users/list?error=Cannot+delete+your+own+account");
                return;
            }
        }
        userDAO.delete(id);
        resp.sendRedirect(req.getContextPath() + "/users/list");
    }

    private void loginUser(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        User user = userDAO.authenticate(email, password);
        if (user != null) {
            if ("PENDING".equals(user.getStatus())) {
                req.setAttribute("error", "Your account is pending admin approval. You'll be notified once approved.");
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

    private void registerPassenger(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String name            = req.getParameter("name");
        String email           = req.getParameter("email");
        String password        = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String role            = req.getParameter("registerRole"); // PASSENGER or DRIVER
        String licenseNumber   = req.getParameter("licenseNumber"); // for drivers

        if (role == null || (!"PASSENGER".equals(role) && !"DRIVER".equals(role))) {
            role = "PASSENGER";
        }

        // Basic validation
        if (InputValidator.anyBlank(name, email, password)
                || !InputValidator.isValidEmail(email)
                || !InputValidator.isValidPassword(password)
                || !InputValidator.isValidName(name)) {
            req.setAttribute("error", "Please fill in all fields correctly. Email must be a valid address (e.g. name@example.com). Password must be at least 6 characters.");
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
            req.setAttribute("error", "Please provide your driver licence number.");
            req.setAttribute("tab", "register");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        // Check email uniqueness
        if (userDAO.emailExists(email.trim())) {
            req.setAttribute("error", "An account with this email already exists. Please sign in.");
            req.setAttribute("tab", "register");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        // Hash password before storing
        String hashedPassword = PasswordUtil.hash(password);

        // Create PENDING user
        User pending;
        if ("DRIVER".equals(role)) {
            Driver d = new Driver(name.trim(), email.trim(), hashedPassword, licenseNumber.trim().toUpperCase());
            d.setStatus("PENDING");
            pending = d;
        } else {
            Passenger p = new Passenger(name.trim(), email.trim(), hashedPassword);
            p.setStatus("PENDING");
            pending = p;
        }
        userDAO.save(pending);

        // Redirect to login with success message
        req.setAttribute("success", "Account created! Your request is pending admin approval. You will be able to sign in once an admin reviews and approves your account.");
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }
}
