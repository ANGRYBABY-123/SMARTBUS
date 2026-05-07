package com.smartbus.dao;

import com.smartbus.entity.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.TypedQuery;
import java.util.List;

public class UserDAO extends GenericDAO<User> {

    public UserDAO() {
        super(User.class);
    }

    // JPQL: find user by email
    public User findByEmail(String email) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<User> query = em.createQuery(
                "SELECT u FROM User u WHERE u.email = :email", User.class);
            query.setParameter("email", email);
            return query.getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    // JPQL: find users by role
    public List<User> findByRole(String role) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<User> query = em.createQuery(
                "SELECT u FROM User u WHERE u.role = :role ORDER BY u.name", User.class);
            query.setParameter("role", role);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    // JPQL: authenticate user
    public User authenticate(String email, String password) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<User> query = em.createQuery(
                "SELECT u FROM User u WHERE u.email = :email AND u.password = :password", User.class);
            query.setParameter("email", email);
            query.setParameter("password", password);
            return query.getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    // JPQL: find all users with PENDING status
    public List<User> findPending() {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<User> query = em.createQuery(
                "SELECT u FROM User u WHERE u.status = 'PENDING' ORDER BY u.userId DESC", User.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    // JPQL: search users by name
    public List<User> searchByName(String name) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<User> query = em.createQuery(
                "SELECT u FROM User u WHERE LOWER(u.name) LIKE :name ORDER BY u.name", User.class);
            query.setParameter("name", "%" + name.toLowerCase() + "%");
            return query.getResultList();
        } finally {
            em.close();
        }
    }
}
