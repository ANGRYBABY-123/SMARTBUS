package com.smartbus.listener;

import com.smartbus.dao.UserDAO;
import com.smartbus.dao.TripDAO;
import com.smartbus.util.JPAUtil;
import jakarta.persistence.EntityManager;
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
        scheduler = Executors.newScheduledThreadPool(2);
        scheduler.scheduleAtFixedRate(() -> {
            try {
                purgeDAO.hardDeleteExpiredRemovals();
            } catch (Exception ex) {
                log.log(Level.WARNING, "Pending-removal purge job failed", ex);
            }
        }, 1, 1, TimeUnit.MINUTES);

        // Every 10 minutes, delete SCHEDULED trips whose start time is 30+ minutes in the past
        TripDAO tripDAO = new TripDAO();
        scheduler.scheduleAtFixedRate(() -> {
            try {
                int n = tripDAO.deleteExpiredScheduledTrips();
                if (n > 0) log.info("Auto-deleted " + n + " expired scheduled trip(s).");
            } catch (Exception ex) {
                log.log(Level.WARNING, "Expired-trip cleanup job failed", ex);
            }
        }, 2, 10, TimeUnit.MINUTES);

        // Seed Soshanguve bus stops and routes if the table is empty
        try {
            seedBusStopsAndRoutes();
        } catch (Exception ex) {
            log.log(Level.WARNING, "Bus-stop seeding failed (non-fatal)", ex);
        }
    }

    // ── Seed data ────────────────────────────────────────────────────────────
    private void seedBusStopsAndRoutes() {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            em.getTransaction().begin();

            // ── Routes ──────────────────────────────────────────────────────
            // Only insert if a route with that name doesn't already exist
            Object[][] routeDefs = {
                {"Soshanguve → Pretoria CBD",           "Soshanguve",  "Pretoria CBD",              -25.5051, 28.1019, -25.7454, 28.1879},
                {"Soshanguve → Bosman Station",         "Soshanguve",  "Bosman Station",             -25.5051, 28.1019, -25.7465, 28.1892},
                {"Soshanguve → TUT Pretoria Campus",    "Soshanguve",  "TUT Pretoria Campus",        -25.5051, 28.1019, -25.7313, 28.1648},
                {"Soshanguve → TUT Arcadia Campus",     "Soshanguve",  "TUT Arcadia Campus",         -25.5051, 28.1019, -25.7469, 28.1961},
                {"Soshanguve → TUT Soshanguve Campus",  "Soshanguve",  "TUT Soshanguve Campus",      -25.5510, 28.0875, -25.5358, 28.1065},
                {"Soshanguve → Rosslyn Industrial",     "Soshanguve",  "Rosslyn Industrial Area",    -25.5044, 28.1030, -25.6019, 28.0619},
                {"Soshanguve → Wonderpark Mall",        "Soshanguve",  "Wonderpark Mall",            -25.5254, 28.0701, -25.6427, 28.1381},
                {"Soshanguve → Mabopane Station",       "Soshanguve",  "Mabopane Station",           -25.5488, 28.0902, -25.4938, 28.0665},
                {"Soshanguve → Ga-Rankuwa",             "Soshanguve",  "Ga-Rankuwa",                 -25.5051, 28.1019, -25.6169, 27.9964},
                {"Soshanguve → Medunsa",                "Soshanguve",  "Medunsa",                    -25.5218, 28.0614, -25.6234, 28.0061},
                {"Soshanguve → Hebron",                 "Soshanguve",  "Hebron",                     -25.4971, 28.0588, -25.4388, 28.0283},
                {"Soshanguve → Akasia / Pretoria North","Soshanguve",  "Akasia / Pretoria North",    -25.5254, 28.0701, -25.6614, 28.1358},
            };

            long[] routeIds = new long[routeDefs.length];
            for (int i = 0; i < routeDefs.length; i++) {
                Object[] r = routeDefs[i];
                @SuppressWarnings("unchecked")
                java.util.List<Object> rRows = em.createNativeQuery(
                    "SELECT route_id FROM routes WHERE route_name = ? LIMIT 1")
                    .setParameter(1, r[0]).getResultList();
                Long existing = rRows.isEmpty() ? null : ((Number) rRows.get(0)).longValue();
                if (existing != null) {
                    routeIds[i] = existing;
                } else {
                    em.createNativeQuery(
                        "INSERT INTO routes (route_name, start_location, end_location, start_lat, start_lng, end_lat, end_lng) " +
                        "VALUES (?,?,?,?,?,?,?)")
                        .setParameter(1, r[0]).setParameter(2, r[1]).setParameter(3, r[2])
                        .setParameter(4, r[3]).setParameter(5, r[4])
                        .setParameter(6, r[5]).setParameter(7, r[6])
                        .executeUpdate();
                    routeIds[i] = ((Number) em.createNativeQuery(
                        "SELECT LAST_INSERT_ID()").getSingleResult()).longValue();
                }
            }

            // ── Bus stops ───────────────────────────────────────────────────
            // {name, lat, lng, route-index list (0-based from routeDefs above)}
            Object[][] stops = {
                {"Soshanguve L Bus Stop",              -25.5310, 28.1015, new int[]{0,2,7,6}},
                {"Soshanguve P Bus Stop",              -25.5172, 28.0931, new int[]{1,3,5}},
                {"Soshanguve TT Bus Stop (North)",     -25.5488, 28.0902, new int[]{0,1,7,2}},
                {"Soshanguve TT Bus Stop (South)",     -25.5510, 28.0875, new int[]{4,2,8}},
                {"Soshanguve S Bus Stop",              -25.5254, 28.0701, new int[]{6,11,7}},
                {"Soshanguve H Bus Stop (1)",          -25.5068, 28.1042, new int[]{2,1,0}},
                {"Soshanguve H Bus Stop (2)",          -25.5075, 28.1060, new int[]{5,0}},
                {"Soshanguve X Bus Stop",              -25.5218, 28.0614, new int[]{7,8,9}},
                {"Soshanguve HH Bus Stop",             -25.4959, 28.0793, new int[]{10,7,0}},
                {"Soshanguve LL Bus Stop",             -25.5107, 28.0841, new int[]{2,4,6,0}},
                {"Taxi Rank TR127",                    -25.4971, 28.0588, new int[]{10,8}},
                {"Taxi Rank TR135",                    -25.5035, 28.1037, new int[]{0,5}},
                {"Taxi Rank TR166",                    -25.5392, 28.0458, new int[]{7,8,9}},
                {"Taxi Rank TR065",                    -25.4798, 28.0834, new int[]{10,7}},
                {"Soshanguve Taxi Rank, Mokhetle Dr",  -25.5051, 28.1019, new int[]{0,1,5}},
                {"Sosha Taxi Rank, Soshanguve H",      -25.5044, 28.1030, new int[]{2,3,1}},
            };

            for (Object[] s : stops) {
                @SuppressWarnings("unchecked")
                java.util.List<Object> sRows = em.createNativeQuery(
                    "SELECT stop_id FROM bus_stops WHERE stop_name = ? LIMIT 1")
                    .setParameter(1, s[0]).getResultList();
                Long existingStop = sRows.isEmpty() ? null : ((Number) sRows.get(0)).longValue();
                long stopId;
                if (existingStop != null) {
                    stopId = existingStop;
                } else {
                    em.createNativeQuery(
                        "INSERT INTO bus_stops (stop_name, latitude, longitude) VALUES (?,?,?)")
                        .setParameter(1, s[0]).setParameter(2, s[1]).setParameter(3, s[2])
                        .executeUpdate();
                    stopId = ((Number) em.createNativeQuery(
                        "SELECT LAST_INSERT_ID()").getSingleResult()).longValue();
                }
                for (int ri : (int[]) s[3]) {
                    em.createNativeQuery(
                        "INSERT IGNORE INTO stop_routes (stop_id, route_id) VALUES (?,?)")
                        .setParameter(1, stopId).setParameter(2, routeIds[ri])
                        .executeUpdate();
                }
            }

            em.getTransaction().commit();
            log.info("Bus stops and Soshanguve routes seeded successfully.");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
        }
        JPAUtil.close();
    }
}
