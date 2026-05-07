package com.smartbus.servlet;

import com.smartbus.dao.UserDAO;
import com.smartbus.entity.Driver;
import com.smartbus.entity.Passenger;
import com.smartbus.entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/users/*")
public class UserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if (path == null) path = "/";

        // Public paths — no auth needed
        if ("/login".equals(path) || "/logout".equals(path) || "/register".equals(path)) {
            switch (path) {
                case "/login":
                    req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                    return;
                case "/logout":
                    req.getSession().invalidate();
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
            // Edit existing — update base fields only (role changes on existing users are
            // intentionally kept as a base-field update to avoid complex table migrations)
            User user = userDAO.findById(Long.parseLong(idParam));
            user.setName(name);
            user.setEmail(email);
            user.setRole(role);
            if (pwd != null && !pwd.trim().isEmpty()) {
                user.setPassword(pwd);
            }
            userDAO.save(user);
        } else {
            // New user — persist the correct JPA subtype so JOINED-table rows are created.
            // userDAO.save() calls em.merge() which uses the runtime type for JOINED inheritance.
            if ("DRIVER".equals(role)) {
                Driver driver = new Driver();
                driver.setName(name);
                driver.setEmail(email);
                driver.setPassword(pwd);
                String regNum = req.getParameter("registrationNumber");
                if (regNum == null || regNum.trim().isEmpty()) {
                    regNum = "DRV-" + System.currentTimeMillis() % 100000L;
                }
                driver.setRegistrationNumber(regNum.trim().toUpperCase());
                userDAO.save(driver);
            } else if ("PASSENGER".equals(role)) {
                userDAO.save(new Passenger(name, email, pwd));
            } else {
                userDAO.save(new User(name, email, pwd, role));
            }
        }
        resp.sendRedirect(req.getContextPath() + "/users/list");
    }

    private void deleteUser(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Long id = Long.parseLong(req.getParameter("id"));
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
        if (name == null || name.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || password == null || password.length() < 6) {
            req.setAttribute("error", "Please fill in all fields. Password must be at least 6 characters.");
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
            req.setAttribute("error", "Please provide your driver licence / registration number.");
            req.setAttribute("tab", "register");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        // Check email uniqueness
        if (userDAO.findByEmail(email.trim()) != null) {
            req.setAttribute("error", "An account with this email already exists. Please sign in.");
            req.setAttribute("tab", "register");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        // Create PENDING user
        User pending;
        if ("DRIVER".equals(role)) {
            Driver d = new Driver(name.trim(), email.trim(), password, licenseNumber.trim().toUpperCase());
            d.setStatus("PENDING");
            pending = d;
        } else {
            Passenger p = new Passenger(name.trim(), email.trim(), password);
            p.setStatus("PENDING");
            pending = p;
        }
        userDAO.save(pending);

        // Redirect to login with success message
        req.setAttribute("success", "Account registered! Please wait for admin approval before signing in.");
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }
}
