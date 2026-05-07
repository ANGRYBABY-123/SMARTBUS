package com.smartbus.dao;

import com.smartbus.entity.Route;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import java.util.List;

public class RouteDAO extends GenericDAO<Route> {

    public RouteDAO() {
        super(Route.class);
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
