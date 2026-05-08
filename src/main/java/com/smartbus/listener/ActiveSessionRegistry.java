package com.smartbus.listener;

import com.smartbus.entity.User;
import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpSessionAttributeListener;
import jakarta.servlet.http.HttpSessionBindingEvent;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Tracks active sessions keyed by user ID so that an admin can immediately
 * invalidate a deleted user's session, kicking them back to the login page.
 */
@WebListener
public class ActiveSessionRegistry implements HttpSessionListener, HttpSessionAttributeListener {

    private static final Map<Long, HttpSession> SESSIONS = new ConcurrentHashMap<>();

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        // Nothing needed — the user attribute hasn't been set yet
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        // Clean up when a session expires or is invalidated normally
        SESSIONS.values().remove(se.getSession());
    }

    @Override
    public void attributeAdded(HttpSessionBindingEvent event) {
        if ("loggedUser".equals(event.getName()) && event.getValue() instanceof User) {
            User user = (User) event.getValue();
            SESSIONS.put(user.getUserId(), event.getSession());
        }
    }

    @Override
    public void attributeReplaced(HttpSessionBindingEvent event) {
        if ("loggedUser".equals(event.getName())) {
            // Remove old user mapping
            if (event.getValue() instanceof User) {
                SESSIONS.remove(((User) event.getValue()).getUserId());
            }
            // Register the new user now on the session
            Object newValue = event.getSession().getAttribute("loggedUser");
            if (newValue instanceof User) {
                SESSIONS.put(((User) newValue).getUserId(), event.getSession());
            }
        }
    }

    @Override
    public void attributeRemoved(HttpSessionBindingEvent event) {
        if ("loggedUser".equals(event.getName()) && event.getValue() instanceof User) {
            SESSIONS.remove(((User) event.getValue()).getUserId());
        }
    }

    /**
     * Invalidates the active session for the given user ID, if any.
     * The user's next request will be redirected to the login page by AuthFilter.
     */
    public static void invalidateSessionForUser(Long userId) {
        HttpSession session = SESSIONS.remove(userId);
        if (session != null) {
            try {
                session.invalidate();
            } catch (IllegalStateException ignored) {
                // Session was already invalidated — nothing to do
            }
        }
    }
}
