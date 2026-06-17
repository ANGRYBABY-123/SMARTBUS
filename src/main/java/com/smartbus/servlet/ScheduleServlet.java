package com.smartbus.servlet;

import com.smartbus.entity.Route;
import com.smartbus.entity.Schedule;
import com.smartbus.service.RouteService;
import com.smartbus.service.ScheduleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalTime;
import java.util.List;

@WebServlet("/schedules/*")
public class ScheduleServlet extends HttpServlet {

    private final ScheduleService scheduleDAO = new ScheduleService();
    private final RouteService routeDAO = new RouteService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        if (path == null) path = "/";

        switch (path) {
            case "/list":
                List<Schedule> schedules = scheduleDAO.findAllWithRoute();
                req.setAttribute("schedules", schedules);
                req.getRequestDispatcher("/WEB-INF/views/schedules.jsp").forward(req, resp);
                break;
            case "/new":
                req.setAttribute("routes", routeDAO.findAllOrdered());
                req.getRequestDispatcher("/WEB-INF/views/schedule-form.jsp").forward(req, resp);
                break;
            case "/edit":
                Schedule s = scheduleDAO.findById(Long.parseLong(req.getParameter("id")));
                req.setAttribute("schedule", s);
                req.setAttribute("routes", routeDAO.findAllOrdered());
                req.getRequestDispatcher("/WEB-INF/views/schedule-form.jsp").forward(req, resp);
                break;
            case "/delete":
                scheduleDAO.delete(Long.parseLong(req.getParameter("id")));
                resp.sendRedirect(req.getContextPath() + "/schedules/list");
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/schedules/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if ("/save".equals(req.getPathInfo())) {
            String idParam = req.getParameter("scheduleId");
            Schedule schedule = (idParam != null && !idParam.isEmpty())
                    ? scheduleDAO.findById(Long.parseLong(idParam))
                    : new Schedule();
            Route route = routeDAO.findById(Long.parseLong(req.getParameter("routeId")));
            schedule.setRoute(route);
            String[] days = req.getParameterValues("days");
            schedule.setDaysOfWeek(days != null ? String.join(",", days) : "");
            schedule.setDepartureTime(LocalTime.parse(req.getParameter("departureTime")));
            schedule.setArrivalTime(LocalTime.parse(req.getParameter("arrivalTime")));
            scheduleDAO.save(schedule);
        }
        resp.sendRedirect(req.getContextPath() + "/schedules/list");
    }
}
