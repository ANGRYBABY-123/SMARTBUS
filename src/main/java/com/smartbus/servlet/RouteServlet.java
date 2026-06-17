package com.smartbus.servlet;

import com.smartbus.entity.Route;
import com.smartbus.service.RouteService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/routes/*")
public class RouteServlet extends HttpServlet {

    private final RouteService routeDAO = new RouteService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if (path == null) path = "/";

        switch (path) {
            case "/list":
                List<Route> routes = routeDAO.findAllOrdered();
                req.setAttribute("routes", routes);
                req.getRequestDispatcher("/WEB-INF/views/routes.jsp").forward(req, resp);
                break;
            case "/new":
                req.getRequestDispatcher("/WEB-INF/views/route-form.jsp").forward(req, resp);
                break;
            case "/edit":
                Route route = routeDAO.findById(Long.parseLong(req.getParameter("id")));
                req.setAttribute("route", route);
                req.getRequestDispatcher("/WEB-INF/views/route-form.jsp").forward(req, resp);
                break;
            case "/delete":
                routeDAO.deleteWithDependents(Long.parseLong(req.getParameter("id")));
                resp.sendRedirect(req.getContextPath() + "/routes/list");
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/routes/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if ("/save".equals(req.getPathInfo())) {
            String idParam = req.getParameter("routeId");
            Route route = (idParam != null && !idParam.isEmpty())
                    ? routeDAO.findById(Long.parseLong(idParam))
                    : new Route();
            route.setRouteName(req.getParameter("routeName"));
            route.setStartLocation(req.getParameter("startLocation"));
            route.setEndLocation(req.getParameter("endLocation"));
            String sLat = req.getParameter("startLat"), sLng = req.getParameter("startLng");
            String eLat = req.getParameter("endLat"),   eLng = req.getParameter("endLng");
            route.setStartLat(sLat != null && !sLat.isEmpty() ? Double.parseDouble(sLat) : null);
            route.setStartLng(sLng != null && !sLng.isEmpty() ? Double.parseDouble(sLng) : null);
            route.setEndLat(eLat != null && !eLat.isEmpty() ? Double.parseDouble(eLat) : null);
            route.setEndLng(eLng != null && !eLng.isEmpty() ? Double.parseDouble(eLng) : null);
            routeDAO.save(route);
        }
        resp.sendRedirect(req.getContextPath() + "/routes/list");
    }
}
