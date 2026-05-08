package com.smartbus.dao;

import com.smartbus.entity.Trip;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class TripDAO extends GenericDAO<Trip> {

    public TripDAO() {
        super(Trip.class);
    }

    // JPQL: find trips by status
    public List<Trip> findByStatus(String status) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<Trip> query = em.createQuery(
                "SELECT t FROM Trip t JOIN FETCH t.driver JOIN FETCH t.bus JOIN FETCH t.route " +
                "WHERE t.status = :status ORDER BY t.startTime DESC", Trip.class);
            query.setParameter("status", status);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    // JPQL: find trips by driver ID
    public List<Trip> findByDriver(Long driverId) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<Trip> query = em.createQuery(
                "SELECT t FROM Trip t JOIN FETCH t.driver d JOIN FETCH t.bus JOIN FETCH t.route " +
                "WHERE d.userId = :driverId ORDER BY t.startTime DESC", Trip.class);
            query.setParameter("driverId", driverId);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    // JPQL: find trips by bus ID
    public List<Trip> findByBus(Long busId) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<Trip> query = em.createQuery(
                "SELECT t FROM Trip t JOIN FETCH t.driver JOIN FETCH t.bus b JOIN FETCH t.route " +
                "WHERE b.busId = :busId ORDER BY t.startTime DESC", Trip.class);
            query.setParameter("busId", busId);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    // JPQL: count trips by status
    public Long countByStatus(String status) {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT COUNT(t) FROM Trip t WHERE t.status = :status", Long.class)
                .setParameter("status", status)
                .getSingleResult();
        } finally {
            em.close();
        }
    }

    // JPQL: find single trip by ID with all associations loaded
    public Trip findByIdWithDetails(Long tripId) {
        EntityManager em = getEntityManager();
        try {
            List<Trip> result = em.createQuery(
                "SELECT t FROM Trip t JOIN FETCH t.driver JOIN FETCH t.bus JOIN FETCH t.route " +
                "WHERE t.tripId = :id", Trip.class)
                .setParameter("id", tripId)
                .getResultList();
            return result.isEmpty() ? null : result.get(0);
        } finally {
            em.close();
        }
    }

    // JPQL: find trips by status whose startTime falls on today
    public List<Trip> findTodayByStatus(String status) {
        EntityManager em = getEntityManager();
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay   = startOfDay.plusDays(1);
        try {
            return em.createQuery(
                "SELECT t FROM Trip t JOIN FETCH t.driver JOIN FETCH t.bus JOIN FETCH t.route " +
                "WHERE t.status = :status " +
                "AND t.startTime >= :startOfDay AND t.startTime < :endOfDay " +
                "ORDER BY t.startTime ASC", Trip.class)
                .setParameter("status", status)
                .setParameter("startOfDay", startOfDay)
                .setParameter("endOfDay",   endOfDay)
                .getResultList();
        } finally {
            em.close();
        }
    }

    // JPQL: find trips for a specific driver on today's date, ordered by start time
    public List<Trip> findByDriverAndDate(Long driverId, LocalDate date) {
        EntityManager em = getEntityManager();
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay   = startOfDay.plusDays(1);
        try {
            return em.createQuery(
                "SELECT t FROM Trip t JOIN FETCH t.driver d JOIN FETCH t.bus JOIN FETCH t.route " +
                "WHERE d.userId = :driverId " +
                "AND t.startTime >= :startOfDay AND t.startTime < :endOfDay " +
                "ORDER BY t.startTime ASC", Trip.class)
                .setParameter("driverId", driverId)
                .setParameter("startOfDay", startOfDay)
                .setParameter("endOfDay",   endOfDay)
                .getResultList();
        } finally {
            em.close();
        }
    }

    // JPQL: find all trips with JOIN FETCH for display
    public List<Trip> findAllWithDetails() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT t FROM Trip t JOIN FETCH t.driver JOIN FETCH t.bus JOIN FETCH t.route " +
                "ORDER BY t.startTime DESC", Trip.class).getResultList();
        } finally {
            em.close();
        }
    }
}
