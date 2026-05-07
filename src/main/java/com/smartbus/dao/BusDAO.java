package com.smartbus.dao;

import com.smartbus.entity.Bus;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.TypedQuery;
import java.util.List;

public class BusDAO extends GenericDAO<Bus> {

    public BusDAO() {
        super(Bus.class);
    }

    // JPQL: find bus by registration number
    public Bus findByRegistration(String registrationNumber) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<Bus> query = em.createQuery(
                "SELECT b FROM Bus b WHERE b.registrationNumber = :reg", Bus.class);
            query.setParameter("reg", registrationNumber);
            return query.getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    // JPQL: find buses with capacity >= given value
    public List<Bus> findByMinCapacity(int capacity) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<Bus> query = em.createQuery(
                "SELECT b FROM Bus b WHERE b.capacity >= :capacity ORDER BY b.capacity", Bus.class);
            query.setParameter("capacity", capacity);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    // JPQL: count total buses
    public Long countBuses() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery("SELECT COUNT(b) FROM Bus b", Long.class).getSingleResult();
        } finally {
            em.close();
        }
    }
}
