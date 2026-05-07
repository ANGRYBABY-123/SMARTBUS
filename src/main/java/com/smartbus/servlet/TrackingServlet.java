package com.smartbus.servlet;

import com.smartbus.dao.GpsTrackingDAO;
import com.smartbus.dao.TripDAO;
import com.smartbus.entity.GpsTracking;
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
import java.util.List;

@WebServlet("/tracking/*")
public class TrackingServlet extends HttpServlet {

    private final TripDAO        tripDAO    = new TripDAO();
    private final GpsTrackingDAO gpsDAO     = new GpsTrackingDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null) path = "/";

        switch (path) {
            case "/drive":
                showDrivePage(req, resp);
                break;
            case "/view":
                showViewPage(req, resp);
                break;
            case "/latest":
                getLatest(req, resp);
                break;
            case "/history":
                getHistory(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/driver/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if ("/update".equals(req.getPathInfo())) {
            updateLocation(req, resp);
        }
    }

    private void showDrivePage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Long tripId = Long.parseLong(req.getParameter("tripId"));
        Trip trip = tripDAO.findByIdWithDetails(tripId);
        req.setAttribute("trip", trip);
        req.getRequestDispatcher("/WEB-INF/views/trip-drive.jsp").forward(req, resp);
    }

    private void showViewPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Long tripId = Long.parseLong(req.getParameter("tripId"));
        Trip trip = tripDAO.findByIdWithDetails(tripId);
        req.setAttribute("trip", trip);
        req.getRequestDispatcher("/WEB-INF/views/trip-track.jsp").forward(req, resp);
    }

    private void updateLocation(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json");
        try {
            User user = (User) req.getSession().getAttribute("loggedUser");
            Long tripId = Long.parseLong(req.getParameter("tripId"));
            double lat = Double.parseDouble(req.getParameter("lat"));
            double lng = Double.parseDouble(req.getParameter("lng"));

            Trip trip = tripDAO.findByIdWithDetails(tripId);
            if (trip == null || !"IN_PROGRESS".equals(trip.getStatus())
                    || !trip.getDriver().getUserId().equals(user.getUserId())) {
                resp.getWriter().write("{\"ok\":false}");
                return;
            }

            gpsDAO.save(new GpsTracking(trip, lat, lng, LocalDateTime.now()));
            resp.getWriter().write("{\"ok\":true}");
        } catch (Exception e) {
            resp.getWriter().write("{\"ok\":false}");
        }
    }

    private void getLatest(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json");
        Long tripId = Long.parseLong(req.getParameter("tripId"));
        GpsTracking latest = gpsDAO.findLatestByTrip(tripId);
        if (latest == null) {
            resp.getWriter().write("{\"found\":false}");
        } else {
            resp.getWriter().write(String.format(
                "{\"found\":true,\"lat\":%.7f,\"lng\":%.7f,\"ts\":\"%s\"}",
                latest.getLatitude(), latest.getLongitude(), latest.getTimestamp()));
        }
    }

    /** GET /tracking/history?tripId=X — return all GPS points as [[lat,lng],...] */
    private void getHistory(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();
        try {
            Long tripId = Long.parseLong(req.getParameter("tripId"));
            List<GpsTracking> points = gpsDAO.findAllByTrip(tripId);
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < points.size(); i++) {
                if (i > 0) sb.append(",");
                GpsTracking g = points.get(i);
                sb.append(String.format("[%.7f,%.7f]", g.getLatitude(), g.getLongitude()));
            }
            sb.append("]");
            out.print(sb.toString());
        } catch (Exception e) {
            out.print("[]");
        }
    }

}
