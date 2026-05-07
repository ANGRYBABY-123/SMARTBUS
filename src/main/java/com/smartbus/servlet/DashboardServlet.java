package com.smartbus.servlet;

import com.smartbus.dao.BusDAO;
import com.smartbus.dao.RouteDAO;
import com.smartbus.dao.TripDAO;
import com.smartbus.dao.UserDAO;
import com.smartbus.entity.Trip;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private final BusDAO busDAO = new BusDAO();
    private final TripDAO tripDAO = new TripDAO();
    private final RouteDAO routeDAO = new RouteDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Trip> activeTripsList = tripDAO.findByStatus("IN_PROGRESS");
        req.setAttribute("totalBuses",  busDAO.countBuses());
        req.setAttribute("activeTripsCount", (long) activeTripsList.size());
        req.setAttribute("activeTripsList", activeTripsList);
        req.setAttribute("totalRoutes", routeDAO.findAll().size());
        req.setAttribute("totalUsers",  userDAO.findAll().size());
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }
}
