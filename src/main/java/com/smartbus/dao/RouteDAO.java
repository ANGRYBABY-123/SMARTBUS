package com.smartbus.dao;

import com.smartbus.entity.Route;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import java.util.List;

public class RouteDAO extends GenericDAO<Route> {

    public RouteDAO() {
        super(Route.class);
    }

    /**
     * Delete a route together with all dependent records in the correct FK order:
     * GpsTracking → Notification → Trip → Schedule → DriverSchedule → Route
     * (stop_routes rows cascade automatically via ON DELETE CASCADE)
     */
    public void deleteWithDependents(Long routeId) {
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();

            // 1. GPS tracking rows for trips on this route
            em.createQuery(
                "DELETE FROM GpsTracking g WHERE g.trip.route.routeId = :rid")
                .setParameter("rid", routeId).executeUpdate();

            // 2. Notifications linked to trips on this route
            em.createQuery(
                "DELETE FROM Notification n WHERE n.trip IS NOT NULL AND n.trip.route.routeId = :rid")
                .setParameter("rid", routeId).executeUpdate();

            // 3. Trips on this route
            em.createQuery(
                "DELETE FROM Trip t WHERE t.route.routeId = :rid")
                .setParameter("rid", routeId).executeUpdate();

            // 4. Schedules on this route
            em.createQuery(
                "DELETE FROM Schedule s WHERE s.route.routeId = :rid")
                .setParameter("rid", routeId).executeUpdate();

            // 5. Driver schedules on this route
            em.createQuery(
                "DELETE FROM DriverSchedule ds WHERE ds.route.routeId = :rid")
                .setParameter("rid", routeId).executeUpdate();

            // 6. The route itself (stop_routes join table cascades)
            Route route = em.find(Route.class, routeId);
            if (route != null) em.remove(route);

            em.getTransaction().commit();
        } catch (Exception e) {
            em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    // JPQL: find routes by start location
    public List<Route> findByStartLocation(String location) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<Route> query = em.createQuery(
                "SELECT r FROM Route r WHERE LOWER(r.startLocation) LIKE :loc ORDER BY r.routeName", Route.class);
            query.setParameter("loc", "%" + location.toLowerCase() + "%");
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    // JPQL: find routes between two locations
    public List<Route> findByLocations(String start, String end) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<Route> query = em.createQuery(
                "SELECT r FROM Route r WHERE LOWER(r.startLocation) LIKE :start AND LOWER(r.endLocation) LIKE :end",
                Route.class);
            query.setParameter("start", "%" + start.toLowerCase() + "%");
            query.setParameter("end", "%" + end.toLowerCase() + "%");
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    // JPQL: find all routes ordered by name
    public List<Route> findAllOrdered() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery("SELECT r FROM Route r ORDER BY r.routeName", Route.class).getResultList();
        } finally {
            em.close();
        }
    }
}
