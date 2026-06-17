package com.smartbus.servlet;

import com.smartbus.entity.BusStop;
import com.smartbus.entity.Route;
import com.smartbus.entity.User;
import com.smartbus.service.BusStopService;
import com.smartbus.service.RouteService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/stops/*")
public class StopServlet extends HttpServlet {

    private final BusStopService stopDAO  = new BusStopService();
    private final RouteService   routeDAO = new RouteService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if (path == null) path = "/list";

        switch (path) {
            case "/list":
                listStops(req, resp);
                break;
            case "/new":
                showForm(req, resp, null);
                break;
            case "/edit":
                showForm(req, resp, Long.parseLong(req.getParameter("id")));
                break;
            case "/delete":
                requireAdmin(req, resp);
                stopDAO.delete(Long.parseLong(req.getParameter("id")));
                resp.sendRedirect(req.getContextPath() + "/stops/list");
                break;
            case "/nearest":
                getNearestStops(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/stops/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if ("/save".equals(req.getPathInfo())) {
            saveStop(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/stops/list");
        }
    }

    // ── Admin: list all stops ─────────────────────────────────────────────
    private void listStops(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("stops", stopDAO.findAllWithRoutes());
        req.getRequestDispatcher("/WEB-INF/views/stops.jsp").forward(req, resp);
    }

    // ── Admin: show add/edit form ─────────────────────────────────────────
    private void showForm(HttpServletRequest req, HttpServletResponse resp, Long id)
            throws ServletException, IOException {
        req.setAttribute("allRoutes", routeDAO.findAll());
        if (id != null) {
            req.setAttribute("stop", stopDAO.findByIdWithRoutes(id));
        }
        req.getRequestDispatcher("/WEB-INF/views/stop-form.jsp").forward(req, resp);
    }

    // ── Admin: save/update ────────────────────────────────────────────────
    private void saveStop(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        requireAdmin(req, resp);

        String idParam  = req.getParameter("stopId");
        String name     = req.getParameter("name");
        String latParam = req.getParameter("latitude");
        String lngParam = req.getParameter("longitude");
        String[] ridArr = req.getParameterValues("routeIds");

        BusStop stop;
        if (idParam != null && !idParam.isEmpty()) {
            stop = stopDAO.findByIdWithRoutes(Long.parseLong(idParam));
            if (stop == null) stop = new BusStop();
        } else {
            stop = new BusStop();
        }

        stop.setName(name != null ? name.trim() : "");
        try { stop.setLatitude(Double.parseDouble(latParam)); }
        catch (Exception e) { stop.setLatitude(null); }
        try { stop.setLongitude(Double.parseDouble(lngParam)); }
        catch (Exception e) { stop.setLongitude(null); }

        List<Long> routeIds = new ArrayList<>();
        if (ridArr != null) {
            for (String r : ridArr) {
                try { routeIds.add(Long.parseLong(r)); } catch (Exception ignored) {}
            }
        }

        stopDAO.saveWithRoutes(stop, routeIds);
        resp.sendRedirect(req.getContextPath() + "/stops/list");
    }

    // ── Passenger API: GET /stops/nearest?lat=X&lng=Y ────────────────────
    // Returns JSON: [{stopId, name, lat, lng, distKm, routes:[{name,from,to}]}]
    private void getNearestStops(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            double lat = Double.parseDouble(req.getParameter("lat"));
            double lng = Double.parseDouble(req.getParameter("lng"));
            List<BusStop> stops = stopDAO.findNearby(lat, lng, 3);

            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < stops.size(); i++) {
                BusStop s = stops.get(i);
                if (i > 0) sb.append(",");
                double dist = stopDAO.distanceKm(lat, lng,
                        s.getLatitude()  != null ? s.getLatitude()  : 0,
                        s.getLongitude() != null ? s.getLongitude() : 0);

                sb.append("{")
                  .append("\"stopId\":").append(s.getStopId()).append(",")
                  .append("\"name\":\"").append(esc(s.getName())).append("\",")
                  .append("\"lat\":").append(s.getLatitude()  != null ? s.getLatitude()  : 0).append(",")
                  .append("\"lng\":").append(s.getLongitude() != null ? s.getLongitude() : 0).append(",")
                  .append("\"distKm\":").append(String.format("%.2f", dist)).append(",")
                  .append("\"routes\":[");

                List<Route> routes = s.getRoutes();
                for (int j = 0; j < routes.size(); j++) {
                    Route r = routes.get(j);
                    if (j > 0) sb.append(",");
                    sb.append("{\"name\":\"").append(esc(r.getRouteName())).append("\",")
                      .append("\"from\":\"").append(esc(r.getStartLocation())).append("\",")
                      .append("\"to\":\"").append(esc(r.getEndLocation())).append("\"}");
                }
                sb.append("]}");
            }
            sb.append("]");
            out.print(sb.toString());
        } catch (Exception e) {
            out.print("[]");
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private void requireAdmin(HttpServletRequest req, HttpServletResponse resp) {
        User u = (User) req.getSession().getAttribute("loggedUser");
        if (u == null || !"ADMIN".equals(u.getRole())) {
            throw new SecurityException("Admin access required");
        }
    }
}
