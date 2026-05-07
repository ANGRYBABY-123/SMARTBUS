package com.smartbus.servlet;

import com.smartbus.dao.BusDAO;
import com.smartbus.dao.DriverDAO;
import com.smartbus.dao.RouteDAO;
import com.smartbus.dao.TripDAO;
import com.smartbus.entity.Bus;
import com.smartbus.entity.Driver;
import com.smartbus.entity.Route;
import com.smartbus.entity.Trip;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/trips/*")
public class TripServlet extends HttpServlet {

    private final TripDAO tripDAO = new TripDAO();
    private final DriverDAO driverDAO = new DriverDAO();
    private final BusDAO busDAO = new BusDAO();
    private final RouteDAO routeDAO = new RouteDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if (path == null) path = "/";

        switch (path) {
            case "/list":
                listTrips(req, resp);
                break;
            case "/new":
                showForm(req, resp, null);
                break;
            case "/edit":
                Long id = Long.parseLong(req.getParameter("id"));
                showForm(req, resp, tripDAO.findById(id));
                break;
            case "/delete":
                tripDAO.delete(Long.parseLong(req.getParameter("id")));
                resp.sendRedirect(req.getContextPath() + "/trips/list");
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/trips/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if ("/save".equals(req.getPathInfo())) {
            saveTrip(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/trips/list");
        }
    }

    private void listTrips(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String status = req.getParameter("status");
        List<Trip> trips;
        if (status != null && !status.isEmpty()) {
            trips = tripDAO.findByStatus(status);
        } else {
            trips = tripDAO.findAllWithDetails();
        }
        req.setAttribute("trips", trips);
        req.getRequestDispatcher("/WEB-INF/views/trips.jsp").forward(req, resp);
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, Trip trip)
            throws ServletException, IOException {
        req.setAttribute("trip", trip);
        req.setAttribute("drivers", driverDAO.findAll());
        req.setAttribute("buses", busDAO.findAll());
        req.setAttribute("routes", routeDAO.findAllOrdered());
        req.getRequestDispatcher("/WEB-INF/views/trip-form.jsp").forward(req, resp);
    }

    private void saveTrip(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String idParam = req.getParameter("tripId");
        Trip trip = (idParam != null && !idParam.isEmpty())
                ? tripDAO.findById(Long.parseLong(idParam))
                : new Trip();

        Driver driver = driverDAO.findById(Long.parseLong(req.getParameter("driverId")));
        Bus bus = busDAO.findById(Long.parseLong(req.getParameter("busId")));
        Route route = routeDAO.findById(Long.parseLong(req.getParameter("routeId")));

        trip.setDriver(driver);
        trip.setBus(bus);
        trip.setRoute(route);
        trip.setStatus(req.getParameter("status"));

        String startTime = req.getParameter("startTime");
        if (startTime != null && !startTime.isEmpty()) {
            trip.setStartTime(LocalDateTime.parse(startTime));
        }
        String endTime = req.getParameter("endTime");
        if (endTime != null && !endTime.isEmpty()) {
            trip.setEndTime(LocalDateTime.parse(endTime));
        }

        tripDAO.save(trip);
        resp.sendRedirect(req.getContextPath() + "/trips/list");
    }
}
