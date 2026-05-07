package com.smartbus.dao;

import com.smartbus.entity.Notification;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class NotificationDAO extends GenericDAO<Notification> {

    public NotificationDAO() {
        super(Notification.class);
    }

    /** All notifications for a trip, ordered newest first. */
    @SuppressWarnings("unchecked")
    public List<Notification> findByTrip(Long tripId) {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT n FROM Notification n WHERE n.trip.tripId = :tripId ORDER BY n.notificationId ASC")
                .setParameter("tripId", tripId)
                .setMaxResults(100)
                .getResultList();
        } catch (Exception e) {
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    /** Trip notifications with id > sinceId (for incremental polling). */
    @SuppressWarnings("unchecked")
    public List<Notification> findByTripSince(Long tripId, Long sinceId) {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT n FROM Notification n WHERE n.trip.tripId = :tripId AND n.notificationId > :sinceId ORDER BY n.notificationId ASC")
                .setParameter("tripId", tripId)
                .setParameter("sinceId", sinceId)
                .setMaxResults(50)
                .getResultList();
        } catch (Exception e) {
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    /** All unread notifications for a user. */
    @SuppressWarnings("unchecked")
    public List<Notification> findUnreadByUser(Long userId) {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT n FROM Notification n WHERE n.user.userId = :userId AND n.isRead = false ORDER BY n.notificationId DESC")
                .setParameter("userId", userId)
                .setMaxResults(20)
                .getResultList();
        } catch (Exception e) {
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    /**
     * Recent DELAY notifications for all active/recent trips (for passenger dashboard bell).
     * Returns up to 20 delay notifications from the last 24 hours.
     */
    @SuppressWarnings("unchecked")
    public List<Notification> findRecentDelayNotifications() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT n FROM Notification n WHERE n.type = 'DELAY' AND n.timestamp > :since " +
                "ORDER BY n.notificationId DESC")
                .setParameter("since", LocalDateTime.now().minusHours(24))
                .setMaxResults(20)
                .getResultList();
        } catch (Exception e) {
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    /** True if a notification of the given type was saved for this trip within the last N minutes. */
    public boolean hasRecentNotifOfType(Long tripId, String type, int minutesBack) {
        EntityManager em = getEntityManager();
        try {
            Long count = em.createQuery(
                "SELECT COUNT(n) FROM Notification n WHERE n.trip.tripId = :tripId " +
                "AND n.type = :type AND n.timestamp > :since", Long.class)
                .setParameter("tripId", tripId)
                .setParameter("type", type)
                .setParameter("since", LocalDateTime.now().minusMinutes(minutesBack))
                .getSingleResult();
            return count != null && count > 0;
        } catch (Exception e) {
            return false;
        } finally {
            em.close();
        }
    }

    /** Latest DELAY or AI_DELAY notification for a trip (for passenger banner). */
    public Notification findLatestDelayForTrip(Long tripId) {
        EntityManager em = getEntityManager();
        try {
            List<Notification> result = em.createQuery(
                "SELECT n FROM Notification n WHERE n.trip.tripId = :tripId " +
                "AND n.type IN :types ORDER BY n.timestamp DESC", Notification.class)
                .setParameter("tripId", tripId)
                .setParameter("types", Arrays.asList("DELAY", "AI_DELAY"))
                .setMaxResults(1)
                .getResultList();
            return result.isEmpty() ? null : result.get(0);
        } catch (Exception e) {
            return null;
        } finally {
            em.close();
        }
    }

    /** Mark a single notification as read. */
    public void markRead(Long notificationId) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Notification n = em.find(Notification.class, notificationId);
            if (n != null) {
                n.setRead(true);
                em.merge(n);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
        } finally {
            em.close();
        }
    }

    /** SCHEDULE-type notifications for a driver, newest first (max 10). */
    @SuppressWarnings("unchecked")
    public List<Notification> findScheduleNotificationsByUser(Long userId) {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT n FROM Notification n " +
                "WHERE n.user.userId = :userId AND n.type = 'SCHEDULE' " +
                "ORDER BY n.timestamp DESC")
                .setParameter("userId", userId)
                .setMaxResults(10)
                .getResultList();
        } catch (Exception e) {
            return java.util.Collections.emptyList();
        } finally {
            em.close();
        }
    }
}
