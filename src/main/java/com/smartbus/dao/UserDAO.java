package com.smartbus.dao;

import com.smartbus.entity.User;
import com.smartbus.util.PasswordUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import java.time.LocalDateTime;
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

    /** Search users by partial name match, case-insensitive (Named Query), excluding PENDING_REMOVAL. */
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

    /** Find all users that are ACTIVE (excludes PENDING and PENDING_REMOVAL), ordered by name. */
    public List<User> findAllActive() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT u FROM User u WHERE u.status = 'ACTIVE' ORDER BY u.name",
                User.class).getResultList();
        } finally {
            em.close();
        }
    }

    /** Find all users currently in the 30-minute pending-removal queue. */
    public List<User> findPendingRemoval() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT u FROM User u WHERE u.status = 'PENDING_REMOVAL' ORDER BY u.removalScheduledAt",
                User.class).getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Soft-delete: marks the user PENDING_REMOVAL and stamps the removal time.
     * Also deletes remember-me tokens so cookie-based restore is blocked.
     */
    public void softDelete(Long id) {
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();
            em.createQuery("DELETE FROM RememberMeToken t WHERE t.user.userId = :id")
              .setParameter("id", id).executeUpdate();
            User user = em.find(User.class, id);
            if (user != null) {
                user.setStatus("PENDING_REMOVAL");
                user.setRemovalScheduledAt(LocalDateTime.now());
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /** Restore a PENDING_REMOVAL user back to ACTIVE. */
    public void readmitUser(Long id) {
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();
            User user = em.find(User.class, id);
            if (user != null) {
                user.setStatus("ACTIVE");
                user.setRemovalScheduledAt(null);
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * Hard-deletes users whose 30-minute removal window has expired.
     * Called by the scheduled background job every minute.
     */
    public void hardDeleteExpiredRemovals() {
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();
            LocalDateTime cutoff = LocalDateTime.now().minusMinutes(30);
            List<User> expired = em.createQuery(
                "SELECT u FROM User u WHERE u.status = 'PENDING_REMOVAL' AND u.removalScheduledAt <= :cutoff",
                User.class)
                .setParameter("cutoff", cutoff)
                .getResultList();
            for (User u : expired) {
                em.createQuery("DELETE FROM Notification n WHERE n.user.userId = :id")
                  .setParameter("id", u.getUserId()).executeUpdate();
                em.createQuery("DELETE FROM RememberMeToken t WHERE t.user.userId = :id")
                  .setParameter("id", u.getUserId()).executeUpdate();
                User managed = em.contains(u) ? u : em.merge(u);
                em.remove(managed);
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
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
