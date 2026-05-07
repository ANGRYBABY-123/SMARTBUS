package com.smartbus.servlet;

import com.smartbus.dao.TripDAO;
import com.smartbus.entity.Trip;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/passenger/*")
public class PassengerServlet extends HttpServlet {

    private TripDAO tripDAO;

    @Override
    public void init() {
        tripDAO = new TripDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null) path = "/dashboard";

        switch (path) {
            case "/dashboard":
                showDashboard(req, resp);
                break;
            case "/track":
                String tripId = req.getParameter("tripId");
                resp.sendRedirect(req.getContextPath() + "/tracking/view?tripId=" + tripId);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/passenger/dashboard");
        }
    }

    private void showDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Trip> activeTrips = tripDAO.findByStatus("IN_PROGRESS");
        List<Trip> scheduledTrips = tripDAO.findByStatus("SCHEDULED");
        req.setAttribute("activeTrips", activeTrips);
        req.setAttribute("scheduledTrips", scheduledTrips);
        req.getRequestDispatcher("/WEB-INF/views/passenger-dashboard.jsp").forward(req, resp);
    }
}
