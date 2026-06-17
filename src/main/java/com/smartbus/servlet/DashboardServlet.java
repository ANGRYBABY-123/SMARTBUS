package com.smartbus.servlet;

import com.smartbus.entity.Trip;
import com.smartbus.service.BusService;
import com.smartbus.service.DriverScheduleService;
import com.smartbus.service.RouteService;
import com.smartbus.service.TripService;
import com.smartbus.service.UserService;
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

    private final BusService busDAO = new BusService();
    private final TripService tripDAO = new TripService();
    private final RouteService routeDAO = new RouteService();
    private final UserService userDAO = new UserService();
    private final DriverScheduleService dsDAO = new DriverScheduleService();

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
        req.setAttribute("pendingUsersCount", (long) userDAO.findPending().size());
        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
    }
}
