package com.smartbus.servlet;

import com.smartbus.dao.TripDAO;
import com.smartbus.entity.Trip;
import com.smartbus.entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/driver/*")
public class DriverServlet extends HttpServlet {

    private final TripDAO tripDAO = new TripDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null) path = "/";

        switch (path) {
            case "/dashboard":
                showDashboard(req, resp);
                break;
            case "/start":
                changeStatus(req, resp, "IN_PROGRESS");
                break;
            case "/end":
                changeStatus(req, resp, "COMPLETED");
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/driver/dashboard");
        }
    }

    private void showDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("loggedUser");
        List<Trip> trips = tripDAO.findByDriver(user.getUserId());
        req.setAttribute("trips", trips);
        req.getRequestDispatcher("/WEB-INF/views/driver-dashboard.jsp").forward(req, resp);
    }

    private void changeStatus(HttpServletRequest req, HttpServletResponse resp, String newStatus)
            throws IOException {
        User user = (User) req.getSession().getAttribute("loggedUser");
        Long tripId = Long.parseLong(req.getParameter("id"));
        Trip trip = tripDAO.findByIdWithDetails(tripId);

        // Only the assigned driver can change their own trip
        if (trip == null || !trip.getDriver().getUserId().equals(user.getUserId())) {
            resp.sendRedirect(req.getContextPath() + "/driver/dashboard");
            return;
        }

        if ("IN_PROGRESS".equals(newStatus)) {
            trip.setStartTime(LocalDateTime.now());
        } else if ("COMPLETED".equals(newStatus)) {
            trip.setEndTime(LocalDateTime.now());
        }
        trip.setStatus(newStatus);
        tripDAO.save(trip);

        if ("IN_PROGRESS".equals(newStatus)) {
            resp.sendRedirect(req.getContextPath() + "/tracking/drive?tripId=" + tripId);
        } else {
            resp.sendRedirect(req.getContextPath() + "/driver/dashboard");
        }
    }
}
