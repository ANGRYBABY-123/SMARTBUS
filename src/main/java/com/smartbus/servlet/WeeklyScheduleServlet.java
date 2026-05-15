package com.smartbus.servlet;

import com.smartbus.dao.*;
import com.smartbus.entity.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet("/weekly-schedule/*")
public class WeeklyScheduleServlet extends HttpServlet {

    private final DriverScheduleDAO dsDAO     = new DriverScheduleDAO();
    private final TripDAO           tripDAO   = new TripDAO();
    private final NotificationDAO   notifDAO  = new NotificationDAO();
    private final DriverDAO         driverDAO = new DriverDAO();
    private final BusDAO            busDAO    = new BusDAO();
    private final RouteDAO          routeDAO  = new RouteDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if (path == null) path = "/";

        switch (path) {
            case "/list":   showList(req, resp);   break;
            case "/new":    showForm(req, resp, null); break;
            case "/edit":   showForm(req, resp, req.getParameter("id")); break;
            case "/delete": deleteEntry(req, resp); break;
            default:
                resp.sendRedirect(req.getContextPath() + "/weekly-schedule/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if (path == null) path = "/";

        switch (path) {
            case "/publish": publishWeek(req, resp);  break;
            case "/save":    saveEntry(req, resp);     break;
            default:
                resp.sendRedirect(req.getContextPath() + "/weekly-schedule/list");
        }
    }

    // ---------------------------------------------------------------

    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Resolve the selected week (default = current week's Monday)
        LocalDate weekStart;
        String weekParam = req.getParameter("week");
        if (weekParam != null && !weekParam.isEmpty()) {
            weekStart = LocalDate.parse(weekParam).with(DayOfWeek.MONDAY);
        } else {
            weekStart = LocalDate.now().with(DayOfWeek.MONDAY);
        }

        List<DriverSchedule> entries  = dsDAO.findByWeek(weekStart);
        List<LocalDate>      weeks    = dsDAO.findDistinctWeeks();
        long                 unpublished = dsDAO.countUnpublished(weekStart);
        List<Trip>           weekTrips   = tripDAO.findByWeek(weekStart);

        // Carry flash message from previous action (publish confirmation)
        String flash = (String) req.getSession().getAttribute("flashMsg");
        if (flash != null) {
            req.setAttribute("flashMsg", flash);
            req.getSession().removeAttribute("flashMsg");
        }

        req.setAttribute("entries",     entries);
        req.setAttribute("weeks",       weeks);
        req.setAttribute("weekStart",   weekStart);
        req.setAttribute("unpublished", unpublished);
        req.setAttribute("weekTrips",   weekTrips);
        req.getRequestDispatcher("/WEB-INF/views/weekly-schedule.jsp").forward(req, resp);
    }

    private void publishWeek(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        LocalDate weekStart = LocalDate.parse(req.getParameter("weekStartDate"))
                                       .with(DayOfWeek.MONDAY);

        List<DriverSchedule> entries = dsDAO.findByWeek(weekStart);
        DateTimeFormatter labelFmt = DateTimeFormatter.ofPattern("dd MMM yyyy");
        int published = 0;

        for (DriverSchedule ds : entries) {
            if (ds.isPublished()) continue;

            // ── Create a trip for each weekday (Mon–Fri) ──────────────
            for (int day = 0; day < 5; day++) {
                LocalDate    tripDate = weekStart.plusDays(day);
                LocalDateTime startDT = tripDate.atTime(ds.getShiftStart());
                LocalDateTime endDT   = tripDate.atTime(ds.getShiftEnd());

                Trip trip = new Trip(ds.getDriver(), ds.getBus(), ds.getRoute(), startDT, "SCHEDULED");
                trip.setEndTime(endDT);
                tripDAO.save(trip);
            }

            // ── Send notification to the driver ────────────────────────
            String weekLabel = weekStart.format(labelFmt);
            String msg = "Your schedule for the week of " + weekLabel + " has been posted. "
                    + "Route: " + ds.getRoute().getRouteName()
                    + " (" + ds.getRoute().getStartLocation() + " \u2192 " + ds.getRoute().getEndLocation() + ")"
                    + " | Bus: " + ds.getBus().getRegistrationNumber()
                    + " | Shift: " + ds.getShiftType()
                    + " " + ds.getShiftStart() + "\u2013" + ds.getShiftEnd();

            notifDAO.save(new Notification(ds.getDriver(), null, msg, "SCHEDULE", LocalDateTime.now()));

            ds.setPublished(true);
            dsDAO.save(ds);
            published++;
        }

        req.getSession().setAttribute("flashMsg",
                published + " schedule entr" + (published == 1 ? "y" : "ies")
                + " published. Trips (Mon\u2013Fri) and driver notifications have been created.");

        resp.sendRedirect(req.getContextPath() + "/weekly-schedule/list?week=" + weekStart);
    }

    // ── Show the add/edit form ────────────────────────────────────────────────
    private void showForm(HttpServletRequest req, HttpServletResponse resp, String idParam)
            throws ServletException, IOException {

        DriverSchedule ds = null;
        if (idParam != null && !idParam.isBlank()) {
            try {
                ds = dsDAO.findById(Long.parseLong(idParam));
            } catch (NumberFormatException ignored) {}
        }

        req.setAttribute("ds",      ds);
        req.setAttribute("drivers", driverDAO.findAllDrivers());
        req.setAttribute("buses",   busDAO.findAll());
        req.setAttribute("routes",  routeDAO.findAll());
        req.getRequestDispatcher("/WEB-INF/views/weekly-schedule-form.jsp").forward(req, resp);
    }

    // ── Save (create or update) a schedule entry ──────────────────────────────
    private void saveEntry(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String dsIdParam = req.getParameter("dsId");

        LocalDate weekStart = LocalDate.parse(req.getParameter("weekStartDate"))
                                       .with(DayOfWeek.MONDAY);
        Driver driver = driverDAO.findById(Long.parseLong(req.getParameter("driverId")));
        Bus    bus    = busDAO.findById(Long.parseLong(req.getParameter("busId")));
        Route  route  = routeDAO.findById(Long.parseLong(req.getParameter("routeId")));
        String shiftType  = req.getParameter("shiftType");
        LocalTime shiftStart = LocalTime.parse(req.getParameter("shiftStart"));
        LocalTime shiftEnd   = LocalTime.parse(req.getParameter("shiftEnd"));

        DriverSchedule ds;
        if (dsIdParam != null && !dsIdParam.isBlank()) {
            ds = dsDAO.findById(Long.parseLong(dsIdParam));
            ds.setPublished(false); // reset publish state on edit
        } else {
            ds = new DriverSchedule();
        }
        ds.setDriver(driver);
        ds.setBus(bus);
        ds.setRoute(route);
        ds.setShiftType(shiftType);
        ds.setShiftStart(shiftStart);
        ds.setShiftEnd(shiftEnd);
        ds.setWeekStartDate(weekStart);
        dsDAO.save(ds);

        resp.sendRedirect(req.getContextPath() + "/weekly-schedule/list?week=" + weekStart);
    }

    // ── Delete a schedule entry ───────────────────────────────────────────────
    private void deleteEntry(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idParam = req.getParameter("id");
        String week = req.getParameter("week");
        if (idParam != null && !idParam.isBlank()) {
            dsDAO.delete(Long.parseLong(idParam));
        }
        String redirect = req.getContextPath() + "/weekly-schedule/list";
        if (week != null && !week.isBlank()) redirect += "?week=" + week;
        resp.sendRedirect(redirect);
    }
}
