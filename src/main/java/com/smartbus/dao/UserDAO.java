package com.smartbus.dao;

import com.smartbus.entity.User;
import com.smartbus.util.PasswordUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import java.util.List;

public class UserDAO extends GenericDAO<User> {

    public UserDAO() {
        super(User.class);
    }

    /** Find a single user by email address (Named Query). */
    public User findByEmail(String email) {
        EntityManager em = getEntityManager();
        try {
            return em.createNamedQuery("User.findByEmail", User.class)
                     .setParameter("email", email)
                     .getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    /** Find a user by their Google OAuth subject identifier (Named Query). */
    public User findByGoogleId(String googleId) {
        EntityManager em = getEntityManager();
        try {
            return em.createNamedQuery("User.findByGoogleId", User.class)
                     .setParameter("googleId", googleId)
                     .getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    /** Find users by role, ordered by name (Named Query). */
    public List<User> findByRole(String role) {
        EntityManager em = getEntityManager();
        try {
            return em.createNamedQuery("User.findByRole", User.class)
                     .setParameter("role", role)
                     .getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Authenticate by email + plain-text password using BCrypt verification.
     * Transparently migrates legacy plain-text passwords to BCrypt on first
     * successful login.
     */
    public User authenticate(String email, String plainPassword) {
        User user = findByEmail(email);
        if (user == null || !PasswordUtil.verify(plainPassword, user.getPassword())) {
            return null;
        }
        // Migrate plain-text to BCrypt if needed
        if (!PasswordUtil.isHashed(user.getPassword())) {
            EntityManager em = getEntityManager();
            try {
                em.getTransaction().begin();
                User managed = em.find(User.class, user.getUserId());
                managed.setPassword(PasswordUtil.hash(plainPassword));
                em.getTransaction().commit();
                user.setPassword(managed.getPassword());
            } catch (Exception ex) {
                em.getTransaction().rollback();
            } finally {
                em.close();
            }
        }
        return user;
    }

    /** Find all users with PENDING registration status (Named Query). */
    public List<User> findPending() {
        EntityManager em = getEntityManager();
        try {
            return em.createNamedQuery("User.findByStatus", User.class)
                     .setParameter("status", "PENDING")
                     .getResultList();
        } finally {
            em.close();
        }
    }

    /** Search users by partial name match, case-insensitive (Named Query). */
    public List<User> searchByName(String name) {
        EntityManager em = getEntityManager();
        try {
            return em.createNamedQuery("User.searchByName", User.class)
                     .setParameter("name", "%" + name.toLowerCase() + "%")
                     .getResultList();
        } finally {
            em.close();
        }
    }

    /** Returns true if the email address is already registered. */
    public boolean emailExists(String email) {
        EntityManager em = getEntityManager();
        try {
            Long count = em.createNamedQuery("User.countByEmail", Long.class)
                           .setParameter("email", email)
                           .getSingleResult();
            return count != null && count > 0;
        } finally {
            em.close();
        }
    }

    /** Delete a user and all related records (notifications, remember-me tokens). */
    @Override
    public void delete(Long id) {
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();
            // Remove child records that may not have CASCADE set by Hibernate
            em.createQuery("DELETE FROM Notification n WHERE n.user.userId = :id").setParameter("id", id).executeUpdate();
            em.createQuery("DELETE FROM RememberMeToken t WHERE t.user.userId = :id").setParameter("id", id).executeUpdate();
            User user = em.find(User.class, id);
            if (user != null) {
                em.remove(user);
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}
