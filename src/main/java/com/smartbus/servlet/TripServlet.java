package com.smartbus.servlet;

import com.smartbus.dao.ScheduleDAO;
import com.smartbus.dao.TripDAO;
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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if (path == null) path = "/";

        switch (path) {
            case "/list":
                listTrips(req, resp);
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
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
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
