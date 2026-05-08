package com.smartbus.servlet;

import com.smartbus.dao.BusDAO;
import com.smartbus.dao.DriverScheduleDAO;
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
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private final BusDAO busDAO = new BusDAO();
    private final TripDAO tripDAO = new TripDAO();
    private final RouteDAO routeDAO = new RouteDAO();
    private final UserDAO userDAO = new UserDAO();
    private final DriverScheduleDAO dsDAO = new DriverScheduleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Trip> activeTripsList = tripDAO.findByStatus("IN_PROGRESS");

        LocalDate weekStart = LocalDate.now().with(DayOfWeek.MONDAY);
        long unpublishedThisWeek = dsDAO.countUnpublished(weekStart);
        long totalThisWeek = dsDAO.findByWeek(weekStart).size();

        req.setAttribute("totalBuses",  busDAO.countBuses());
        req.setAttribute("activeTripsCount", (long) activeTripsList.size());
        req.setAttribute("activeTripsList", activeTripsList);
        req.setAttribute("totalRoutes", routeDAO.findAll().size());
        req.setAttribute("totalUsers",  userDAO.findAll().size());
        req.setAttribute("weekStart",   weekStart);
        req.setAttribute("unpublishedThisWeek", unpublishedThisWeek);
        req.setAttribute("totalThisWeek", totalThisWeek);
        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
    }
}
