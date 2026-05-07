package com.smartbus.dao;

import com.smartbus.entity.GpsTracking;
import jakarta.persistence.EntityManager;
import java.util.Collections;
import java.util.List;

public class GpsTrackingDAO extends GenericDAO<GpsTracking> {

    public GpsTrackingDAO() {
        super(GpsTracking.class);
    }

    public GpsTracking findLatestByTrip(Long tripId) {
        EntityManager em = getEntityManager();
        try {
            List<GpsTracking> result = em.createQuery(
                "SELECT g FROM GpsTracking g WHERE g.trip.tripId = :tripId ORDER BY g.timestamp DESC",
                GpsTracking.class)
                .setParameter("tripId", tripId)
                .setMaxResults(1)
                .getResultList();
            return result.isEmpty() ? null : result.get(0);
        } finally {
            em.close();
        }
    }

    /** Return the most recent N GPS points for a trip, ordered oldest-first (for speed calc). */
    public List<GpsTracking> findRecentByTrip(Long tripId, int limit) {
        EntityManager em = getEntityManager();
        try {
            List<GpsTracking> result = em.createQuery(
                "SELECT g FROM GpsTracking g WHERE g.trip.tripId = :tripId ORDER BY g.timestamp DESC",
                GpsTracking.class)
                .setParameter("tripId", tripId)
                .setMaxResults(limit)
                .getResultList();
            Collections.reverse(result); // oldest-first for sequential speed calculation
            return result;
        } finally {
            em.close();
        }
    }

    /** Return all GPS points for a trip ordered oldest-first, capped at 500 points. */
    public List<GpsTracking> findAllByTrip(Long tripId) {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT g FROM GpsTracking g WHERE g.trip.tripId = :tripId ORDER BY g.timestamp ASC",
                GpsTracking.class)
                .setParameter("tripId", tripId)
                .setMaxResults(500)
                .getResultList();
        } finally {
            em.close();
        }
    }
}
