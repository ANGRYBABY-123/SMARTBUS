package com.smartbus.servlet;

import com.smartbus.dao.BusDAO;
import com.smartbus.dao.DriverDAO;
import com.smartbus.dao.RouteDAO;
import com.smartbus.dao.ScheduleDAO;
import com.smartbus.dao.TripDAO;
import com.smartbus.entity.Bus;
import com.smartbus.entity.Driver;
import com.smartbus.entity.Route;
import com.smartbus.entity.Schedule;
import com.smartbus.entity.Trip;
import com.smartbus.entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@WebServlet("/trips/*")
public class TripServlet extends HttpServlet {

    private final TripDAO     tripDAO     = new TripDAO();
    private final ScheduleDAO scheduleDAO = new ScheduleDAO();
    private final DriverDAO   driverDAO   = new DriverDAO();
    private final BusDAO      busDAO      = new BusDAO();
    private final RouteDAO    routeDAO    = new RouteDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if (path == null) path = "/";

        switch (path) {
            case "/list":
                listTrips(req, resp);
                break;
            case "/autogenerate":
                showAutoGenerateForm(req, resp);
                break;
            case "/delete":
                tripDAO.delete(Long.parseLong(req.getParameter("id")));
                resp.sendRedirect(req.getContextPath() + "/trips/list");
                break;
            default:
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

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getPathInfo();
        if ("/update-status".equals(path)) {
            updateTripStatus(req, resp);
        } else if ("/autogenerate".equals(path)) {
            autoGenerateTrips(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void showAutoGenerateForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("drivers", driverDAO.findAllDrivers());
        req.setAttribute("buses",   busDAO.findAll());
        req.setAttribute("routes",  routeDAO.findAll());
        req.getRequestDispatcher("/WEB-INF/views/trip-autogenerate.jsp").forward(req, resp);
    }

    private void autoGenerateTrips(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String driverIdParam  = req.getParameter("driverId");
        String busIdParam     = req.getParameter("busId");
        String routeIdParam   = req.getParameter("routeId");
        String dateParam      = req.getParameter("tripDate");
        String startHourParam = req.getParameter("startHour");
        String endHourParam   = req.getParameter("endHour");

        if (driverIdParam == null || busIdParam == null || routeIdParam == null
                || dateParam == null || startHourParam == null || endHourParam == null) {
            resp.sendRedirect(req.getContextPath() + "/trips/autogenerate");
            return;
        }

        int startHour, endHour;
        try {
            startHour = Integer.parseInt(startHourParam);
            endHour   = Integer.parseInt(endHourParam);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/trips/autogenerate");
            return;
        }

        Driver driver = (Driver) driverDAO.findById(Long.parseLong(driverIdParam));
        Bus    bus    = busDAO.findById(Long.parseLong(busIdParam));
        Route  route  = routeDAO.findById(Long.parseLong(routeIdParam));
        LocalDate date = LocalDate.parse(dateParam);

        if (driver == null || bus == null || route == null
                || startHour >= endHour || endHour > 17 || startHour < 0) {
            resp.sendRedirect(req.getContextPath() + "/trips/autogenerate");
            return;
        }

        for (int hour = startHour; hour < endHour; hour++) {
            LocalDateTime start = date.atTime(hour, 0);
            LocalDateTime end   = date.atTime(hour + 1, 0);
            Trip trip = new Trip(driver, bus, route, start, "SCHEDULED");
            trip.setEndTime(end);
            tripDAO.save(trip);
        }

        resp.sendRedirect(req.getContextPath() + "/trips/list");
    }

    private void updateTripStatus(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");

        User user = (User) req.getSession().getAttribute("loggedUser");
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"error\":\"Not logged in\"}");
            return;
        }

        long tripId;
        try { tripId = Long.parseLong(req.getParameter("tripId")); }
        catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Invalid tripId\"}");
            return;
        }

        String status = req.getParameter("status");
        Trip trip = tripDAO.findByIdWithDetails(tripId);

        if (trip == null || !trip.getDriver().getUserId().equals(user.getUserId())) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.getWriter().write("{\"error\":\"Not authorized\"}");
            return;
        }

        if ("IN_PROGRESS".equals(status)) {
            // Time validation: find any schedule for today's day on this route
            String todayAbbrev = LocalDate.now().getDayOfWeek().name().substring(0, 3);
            List<Schedule> schedules = scheduleDAO.findByRoute(trip.getRoute().getRouteId());
            boolean hasScheduleToday = false;
            boolean timeAllowed = false;
            for (Schedule s : schedules) {
                if (s.getDaysOfWeek() != null && s.getDaysOfWeek().contains(todayAbbrev)) {
                    hasScheduleToday = true;
                    LocalTime earliest = s.getDepartureTime().minusMinutes(30);
                    if (!LocalTime.now().isBefore(earliest)) {
                        timeAllowed = true;
                        break;
                    }
                }
            }
            if (hasScheduleToday && !timeAllowed) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                resp.getWriter().write("{\"error\":\"Too early to start — check the schedule for the departure time.\"}");
                return;
            }
            trip.setStartTime(LocalDateTime.now());
        } else if ("COMPLETED".equals(status)) {
            trip.setEndTime(LocalDateTime.now());
        } else {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Invalid status\"}");
            return;
        }

        trip.setStatus(status);
        tripDAO.save(trip);
        resp.getWriter().write("{\"ok\":true}");
    }
}
