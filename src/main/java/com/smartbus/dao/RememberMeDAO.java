package com.smartbus.dao;

import com.smartbus.entity.RememberMeToken;
import com.smartbus.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.TypedQuery;
import java.time.LocalDateTime;
import java.util.List;

public class RememberMeDAO {

    private EntityManager getEntityManager() {
        return JPAUtil.getEntityManagerFactory().createEntityManager();
    }

    public void save(RememberMeToken t) {
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(t);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public RememberMeToken findByToken(String token) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<RememberMeToken> q = em.createQuery(
                "SELECT t FROM RememberMeToken t WHERE t.token = :token AND t.expiresAt > :now",
                RememberMeToken.class);
            q.setParameter("token", token);
            q.setParameter("now", LocalDateTime.now());
            return q.getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    public void deleteByToken(String token) {
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();
            em.createQuery("DELETE FROM RememberMeToken t WHERE t.token = :token")
              .setParameter("token", token)
              .executeUpdate();
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
        } finally {
            em.close();
        }
    }

    public void deleteExpired() {
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();
            em.createQuery("DELETE FROM RememberMeToken t WHERE t.expiresAt <= :now")
              .setParameter("now", LocalDateTime.now())
              .executeUpdate();
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
        } finally {
            em.close();
        }
    }
}
