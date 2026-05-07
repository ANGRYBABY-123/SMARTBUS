package com.smartbus.dao;

import com.smartbus.entity.Driver;
import jakarta.persistence.EntityManager;
import java.util.List;

public class DriverDAO extends GenericDAO<Driver> {

    public DriverDAO() {
        super(Driver.class);
    }

    // JPQL: find all drivers with their trip count
    public List<Driver> findAllDrivers() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery("SELECT d FROM Driver d ORDER BY d.name", Driver.class).getResultList();
        } finally {
            em.close();
        }
    }
}
