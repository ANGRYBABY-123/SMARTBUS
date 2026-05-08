package com.smartbus.listener;

import com.smartbus.dao.UserDAO;
import com.smartbus.util.JPAUtil;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebListener
public class AppContextListener implements ServletContextListener {

    private static final Logger log = Logger.getLogger(AppContextListener.class.getName());
    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Pre-warm the EntityManagerFactory on startup – log but don't crash if DB is unavailable
        try {
            JPAUtil.getEntityManagerFactory();
            log.info("Database connection established successfully.");
        } catch (Exception e) {
            log.log(Level.SEVERE, "Could not connect to database on startup. Check DB_HOST/DB_PORT/DB_NAME/DB_USER/DB_PASS env vars. App will still start.", e);
        }
        // Every 60 s, permanently delete users whose 30-minute removal window has expired
        UserDAO purgeDAO = new UserDAO();
        scheduler = Executors.newSingleThreadScheduledExecutor();
        scheduler.scheduleAtFixedRate(() -> {
            try {
                purgeDAO.hardDeleteExpiredRemovals();
            } catch (Exception ex) {
                log.log(Level.WARNING, "Pending-removal purge job failed", ex);
            }
        }, 1, 1, TimeUnit.MINUTES);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
        }
        JPAUtil.close();
    }
}
