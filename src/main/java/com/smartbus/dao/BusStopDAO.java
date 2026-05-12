package com.smartbus.dao;

import com.smartbus.entity.BusStop;
import com.smartbus.entity.Route;
import jakarta.persistence.EntityManager;
import java.util.ArrayList;
import java.util.List;

public class BusStopDAO extends GenericDAO<BusStop> {

    public BusStopDAO() {
        super(BusStop.class);
    }

    /** All stops with their routes, ordered by name. */
    public List<BusStop> findAllWithRoutes() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT DISTINCT s FROM BusStop s LEFT JOIN FETCH s.routes ORDER BY s.name",
                BusStop.class)
                .getResultList();
        } finally {
            em.close();
        }
    }

    /** Single stop with routes loaded. */
    public BusStop findByIdWithRoutes(Long stopId) {
        EntityManager em = getEntityManager();
        try {
            List<BusStop> result = em.createQuery(
                "SELECT s FROM BusStop s LEFT JOIN FETCH s.routes WHERE s.stopId = :id",
                BusStop.class)
                .setParameter("id", stopId)
                .getResultList();
            return result.isEmpty() ? null : result.get(0);
        } finally {
            em.close();
        }
    }

    /** Nearest stops sorted by haversine distance, with routes loaded. */
    public List<BusStop> findNearby(double lat, double lng, int limit) {
        List<BusStop> all = findAllWithRoutes();
        all.sort((a, b) -> Double.compare(
            distanceKm(lat, lng, a.getLatitude() != null ? a.getLatitude() : 0, a.getLongitude() != null ? a.getLongitude() : 0),
            distanceKm(lat, lng, b.getLatitude() != null ? b.getLatitude() : 0, b.getLongitude() != null ? b.getLongitude() : 0)
        ));
        return all.subList(0, Math.min(limit, all.size()));
    }

    /** Save or update a stop, re-binding its route associations inside a single transaction. */
    public void saveWithRoutes(BusStop stop, List<Long> routeIds) {
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();
            BusStop managed = (stop.getStopId() == null) ? stop : em.merge(stop);
            managed.getRoutes().clear();
            if (routeIds != null) {
                for (Long rid : routeIds) {
                    Route r = em.find(Route.class, rid);
                    if (r != null) managed.getRoutes().add(r);
                }
            }
            em.persist(em.contains(managed) ? managed : em.merge(managed));
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public double distanceKm(double lat1, double lng1, double lat2, double lng2) {
        final double R = 6371;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                 + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                 * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }
}
