package com.smartbus.dao;

import com.smartbus.entity.PasswordResetToken;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import java.time.LocalDateTime;

public class PasswordResetTokenDAO extends GenericDAO<PasswordResetToken> {

    public PasswordResetTokenDAO() {
        super(PasswordResetToken.class);
    }

    /** Look up a token by its string value; returns null if not found. */
    public PasswordResetToken findByToken(String token) {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                    "SELECT t FROM PasswordResetToken t WHERE t.token = :token",
                    PasswordResetToken.class)
                    .setParameter("token", token)
                    .getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    /** Delete all tokens for a given user (called before creating a new one). */
    public void deleteByUserId(Long userId) {
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();
            em.createQuery(
                    "DELETE FROM PasswordResetToken t WHERE t.userId = :uid")
                    .setParameter("uid", userId)
                    .executeUpdate();
            em.getTransaction().commit();
        } catch (Exception e) {
            em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /** Purge all expired tokens (optional housekeeping). */
    public void deleteExpired() {
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();
            em.createQuery(
                    "DELETE FROM PasswordResetToken t WHERE t.expiry < :now")
                    .setParameter("now", LocalDateTime.now())
                    .executeUpdate();
            em.getTransaction().commit();
        } catch (Exception e) {
            em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}
