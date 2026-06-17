package com.smartbus.servlet;

import com.smartbus.entity.Bus;
import com.smartbus.service.BusService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/buses/*")
public class BusServlet extends HttpServlet {

    private final BusService busDAO = new BusService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if (path == null) path = "/";

        switch (path) {
            case "/list":
                List<Bus> buses = busDAO.findAll();
                req.setAttribute("buses", buses);
                req.getRequestDispatcher("/WEB-INF/views/buses.jsp").forward(req, resp);
                break;
            case "/new":
                req.getRequestDispatcher("/WEB-INF/views/bus-form.jsp").forward(req, resp);
                break;
            case "/edit":
                Bus bus = busDAO.findById(Long.parseLong(req.getParameter("id")));
                req.setAttribute("bus", bus);
                req.getRequestDispatcher("/WEB-INF/views/bus-form.jsp").forward(req, resp);
                break;
            case "/delete":
                busDAO.delete(Long.parseLong(req.getParameter("id")));
                resp.sendRedirect(req.getContextPath() + "/buses/list");
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/buses/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if ("/save".equals(req.getPathInfo())) {
            String idParam = req.getParameter("busId");
            Bus bus = (idParam != null && !idParam.isEmpty())
                    ? busDAO.findById(Long.parseLong(idParam))
                    : new Bus();
            bus.setRegistrationNumber(req.getParameter("registrationNumber"));
            bus.setCapacity(Integer.parseInt(req.getParameter("capacity")));
            busDAO.save(bus);
        }
        resp.sendRedirect(req.getContextPath() + "/buses/list");
    }
}
