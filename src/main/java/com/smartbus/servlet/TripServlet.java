package com.smartbus.servlet;

import com.smartbus.entity.Bus;
import com.smartbus.entity.Driver;
import com.smartbus.entity.Route;
import com.smartbus.entity.Schedule;
import com.smartbus.entity.Trip;
import com.smartbus.entity.User;
import com.smartbus.service.BusService;
import com.smartbus.service.DriverService;
import com.smartbus.service.RouteService;
import com.smartbus.service.ScheduleService;
import com.smartbus.service.TripService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet("/trips/*")
public class TripServlet extends HttpServlet {

    private final TripService     tripDAO     = new TripService();
    private final ScheduleService scheduleDAO = new ScheduleService();
    private final DriverService   driverDAO   = new DriverService();
    private final BusService      busDAO      = new BusService();
    private final RouteService    routeDAO    = new RouteService();

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
            case "/alternatives":
                getAlternatives(req, resp);
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

    // GET /trips/alternatives?tripId=X  → JSON array of alternative active/upcoming trips
    private void getAlternatives(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        try {
            Long tripId = Long.parseLong(req.getParameter("tripId"));
            Trip current = tripDAO.findByIdWithDetails(tripId);
            if (current == null) { out.print("[]"); return; }
            List<Trip> alts = tripDAO.findAlternatives(current.getRoute().getRouteId());
            DateTimeFormatter fmt = DateTimeFormatter.ofPattern("HH:mm");
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < alts.size(); i++) {
                Trip t = alts.get(i);
                if (i > 0) sb.append(",");
                String time = t.getStartTime() != null ? t.getStartTime().format(fmt) : "--";
                sb.append("{");
                sb.append("\"tripId\":").append(t.getTripId()).append(",");
                sb.append("\"route\":\"").append(esc(t.getRoute().getRouteName())).append("\",");
                sb.append("\"from\":\"").append(esc(t.getRoute().getStartLocation())).append("\",");
                sb.append("\"to\":\"").append(esc(t.getRoute().getEndLocation())).append("\",");
                sb.append("\"driver\":\"").append(esc(t.getDriver().getName())).append("\",");
                sb.append("\"bus\":\"").append(esc(t.getBus().getRegistrationNumber())).append("\",");
                sb.append("\"status\":\"").append(esc(t.getStatus())).append("\",");
                sb.append("\"startTime\":\"").append(time).append("\"");
                sb.append("}");
            }
            sb.append("]");
            out.print(sb.toString());
        } catch (Exception e) {
            out.print("[]");
        }
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
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
