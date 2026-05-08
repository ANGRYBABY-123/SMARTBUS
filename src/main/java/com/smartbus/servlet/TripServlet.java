package com.smartbus.servlet;

import com.smartbus.dao.TripDAO;
import com.smartbus.entity.Trip;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/trips/*")
public class TripServlet extends HttpServlet {

    private final TripDAO tripDAO = new TripDAO();

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
}
