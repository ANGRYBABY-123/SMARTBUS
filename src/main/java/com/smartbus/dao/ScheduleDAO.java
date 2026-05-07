package com.smartbus.dao;

import com.smartbus.entity.Schedule;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import java.util.List;

public class ScheduleDAO extends GenericDAO<Schedule> {

    public ScheduleDAO() {
        super(Schedule.class);
    }

    // JPQL: find schedules by route
    public List<Schedule> findByRoute(Long routeId) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<Schedule> query = em.createQuery(
                "SELECT s FROM Schedule s JOIN FETCH s.route r WHERE r.routeId = :routeId " +
                "ORDER BY s.departureTime", Schedule.class);
            query.setParameter("routeId", routeId);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    // JPQL: find all schedules with route details
    public List<Schedule> findAllWithRoute() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT s FROM Schedule s JOIN FETCH s.route ORDER BY s.route.routeName, s.departureTime",
                Schedule.class).getResultList();
        } finally {
            em.close();
        }
    }
}
