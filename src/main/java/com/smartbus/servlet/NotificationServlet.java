package com.smartbus.servlet;

import com.smartbus.dao.NotificationDAO;
import com.smartbus.dao.TripDAO;
import com.smartbus.entity.Notification;
import com.smartbus.entity.Trip;
import com.smartbus.entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet("/notifications/*")
public class NotificationServlet extends HttpServlet {

    private final NotificationDAO notifDAO = new NotificationDAO();
    private final TripDAO         tripDAO  = new TripDAO();

    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");

    // ── GET /notifications/trip?tripId=X&since=Y ─────────────────────────
    // Returns trip-level notifications (delay alerts etc.) as JSON array.
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("loggedUser");
        if (user == null) { resp.sendError(HttpServletResponse.SC_UNAUTHORIZED); return; }

        String path = req.getPathInfo();
        if (path == null) path = "/";

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        switch (path) {
            case "/trip":
                getTripNotifications(req, out);
                break;
            case "/unread":
                getUnreadForUser(user, out);
                break;
            case "/latest-delay":
                getLatestDelay(req, out);
                break;
            default:
                out.print("[]");
        }
    }

    private void getTripNotifications(HttpServletRequest req, PrintWriter out) {
        try {
            long tripId  = Long.parseLong(req.getParameter("tripId"));
            long sinceId = req.getParameter("since") != null
                           ? Long.parseLong(req.getParameter("since")) : 0L;

            List<Notification> notifications = sinceId > 0
                ? notifDAO.findByTripSince(tripId, sinceId)
                : notifDAO.findByTrip(tripId);

            out.print(toJsonArray(notifications));
        } catch (Exception e) {
            out.print("[]");
        }
    }

    private void getLatestDelay(HttpServletRequest req, PrintWriter out) {
        try {
            long tripId = Long.parseLong(req.getParameter("tripId"));
            Notification n = notifDAO.findLatestDelayForTrip(tripId);
            if (n == null) {
                out.print("{\"hasDelay\":false}");
            } else {
                out.print("{\"hasDelay\":true,\"message\":\"" + escapeJson(n.getMessage())
                    + "\",\"type\":\"" + n.getType() + "\"}");
            }
        } catch (Exception e) {
            out.print("{\"hasDelay\":false}");
        }
    }

    private void getUnreadForUser(User user, PrintWriter out) {
        try {
            List<Notification> notifications;
            if ("PASSENGER".equals(user.getRole())) {
                // Passengers see all recent delay notifications for any active trip
                notifications = notifDAO.findRecentDelayNotifications();
            } else {
                notifications = notifDAO.findUnreadByUser(user.getUserId());
            }
            out.print(toJsonArray(notifications));
        } catch (Exception e) {
            out.print("[]");
        }
    }

    // ── POST /notifications/report-delay ────────────────────────────────
    // Driver reports delay. Creates a trip-level notification for the trip.
    // POST /notifications/mark-read  id=X  → marks notification as read.
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("loggedUser");
        if (user == null) { resp.sendError(HttpServletResponse.SC_UNAUTHORIZED); return; }

        String path = req.getPathInfo();
        if (path == null) path = "/";

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        switch (path) {
            case "/report-delay":
                reportDelay(req, resp, user, out);
                break;
            case "/mark-read":
                markRead(req, out);
                break;
            default:
                out.print("{\"ok\":false,\"error\":\"unknown endpoint\"}");
        }
    }

    private void reportDelay(HttpServletRequest req, HttpServletResponse resp,
                             User driver, PrintWriter out) throws IOException {
        try {
            long   tripId = Long.parseLong(req.getParameter("tripId"));
            String reason = req.getParameter("reason");
            if (reason == null || reason.trim().isEmpty()) reason = "Traffic delay";
            if (reason.length() > 200) reason = reason.substring(0, 200);

            Trip trip = tripDAO.findByIdWithDetails(tripId);
            if (trip == null) {
                out.print("{\"ok\":false,\"error\":\"trip not found\"}"); return;
            }

            // Only the assigned driver (or admin) can report delay
            if (!"ADMIN".equals(driver.getRole()) &&
                !trip.getDriver().getUserId().equals(driver.getUserId())) {
                out.print("{\"ok\":false,\"error\":\"not authorized\"}"); return;
            }

            String message = "⚠️ Delay reported on route " + trip.getRoute().getRouteName()
                           + " (" + trip.getRoute().getStartLocation() + " → "
                           + trip.getRoute().getEndLocation() + "): " + reason
                           + ". Bus: " + trip.getBus().getRegistrationNumber()
                           + ". Driver: " + driver.getName() + ".";

            Notification notif = new Notification(
                driver, trip, message, "DELAY", LocalDateTime.now());
            Notification saved = notifDAO.save(notif);

            out.print("{\"ok\":true,\"id\":" + saved.getNotificationId()
                    + ",\"message\":\"" + escapeJson(message) + "\""
                    + ",\"time\":\"" + saved.getTimestamp().format(TIME_FMT) + "\"}");

        } catch (Exception e) {
            out.print("{\"ok\":false,\"error\":\"server error\"}");
        }
    }

    private void markRead(HttpServletRequest req, PrintWriter out) {
        try {
            long id = Long.parseLong(req.getParameter("id"));
            notifDAO.markRead(id);
            out.print("{\"ok\":true}");
        } catch (Exception e) {
            out.print("{\"ok\":false}");
        }
    }

    private String toJsonArray(List<Notification> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) sb.append(",");
            Notification n = list.get(i);
            sb.append("{")
              .append("\"id\":").append(n.getNotificationId()).append(",")
              .append("\"type\":\"").append(escapeJson(n.getType())).append("\",")
              .append("\"message\":\"").append(escapeJson(n.getMessage())).append("\",")
              .append("\"time\":\"").append(n.getTimestamp().format(TIME_FMT)).append("\",")
              .append("\"read\":").append(n.isRead())
              .append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
