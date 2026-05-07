package com.smartbus.dao;

import com.smartbus.entity.DriverSchedule;
import jakarta.persistence.EntityManager;
import java.time.LocalDate;
import java.util.List;

public class DriverScheduleDAO extends GenericDAO<DriverSchedule> {

    public DriverScheduleDAO() {
        super(DriverSchedule.class);
    }

    /** All schedule entries for a given week (Monday), with all associations loaded. */
    public List<DriverSchedule> findByWeek(LocalDate weekStart) {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT ds FROM DriverSchedule ds " +
                "JOIN FETCH ds.driver JOIN FETCH ds.bus JOIN FETCH ds.route " +
                "WHERE ds.weekStartDate = :ws ORDER BY ds.shiftStart",
                DriverSchedule.class)
                .setParameter("ws", weekStart)
                .getResultList();
        } finally {
            em.close();
        }
    }

    /** Current driver's schedule entries for a given week. */
    public List<DriverSchedule> findByDriverAndWeek(Long driverId, LocalDate weekStart) {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT ds FROM DriverSchedule ds " +
                "JOIN FETCH ds.bus JOIN FETCH ds.route " +
                "WHERE ds.driver.userId = :driverId AND ds.weekStartDate = :ws " +
                "ORDER BY ds.shiftStart",
                DriverSchedule.class)
                .setParameter("driverId", driverId)
                .setParameter("ws", weekStart)
                .getResultList();
        } finally {
            em.close();
        }
    }

    /** Distinct week-start dates that have at least one entry, newest first. */
    public List<LocalDate> findDistinctWeeks() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT DISTINCT ds.weekStartDate FROM DriverSchedule ds " +
                "ORDER BY ds.weekStartDate DESC",
                LocalDate.class)
                .getResultList();
        } finally {
            em.close();
        }
    }

    /** How many unpublished entries exist for this week. */
    public long countUnpublished(LocalDate weekStart) {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT COUNT(ds) FROM DriverSchedule ds " +
                "WHERE ds.weekStartDate = :ws AND ds.published = false",
                Long.class)
                .setParameter("ws", weekStart)
                .getSingleResult();
        } finally {
            em.close();
        }
    }
}
