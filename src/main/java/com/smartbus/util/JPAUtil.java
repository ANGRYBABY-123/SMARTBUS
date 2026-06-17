package com.smartbus.util;

import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

public class JPAUtil {

    private static final String PERSISTENCE_UNIT = "SmartBusPU";
    private static final Logger log = Logger.getLogger(JPAUtil.class.getName());
    private static EntityManagerFactory emf;

    private JPAUtil() {}

    public static EntityManagerFactory getEntityManagerFactory() {
        if (emf == null || !emf.isOpen()) {
            Map<String, Object> overrides = buildOverrides();
            emf = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT, overrides);
            logResolvedDatabase(overrides);
        }
        return emf;
    }

    /**
     * Reads optional environment variables so the same WAR can connect to any
     * database server without recompiling.
     *
     * The override is applied ONLY when ALL THREE of DB_HOST, DB_USER and DB_PASS
     * are explicitly set in the environment.  If any one is missing the method
     * returns an empty map and the credentials in persistence.xml are used as-is
     * (which is the correct Railway fallback).
     *
     * Required env vars for a full override:
     *   DB_HOST  – MySQL host (e.g. trolley.proxy.rlwy.net)
     *   DB_PORT  – MySQL port (default: 3306)
     *   DB_NAME  – Schema / database name (default: railway)
     *   DB_USER  – DB username
     *   DB_PASS  – DB password
     */
    private static Map<String, Object> buildOverrides() {
        Map<String, Object> props = new HashMap<>();

        String host = requiredEnv("DB_HOST");
        String user = requiredEnv("DB_USER");
        String pass = requiredEnv("DB_PASS");

        String port = env("DB_PORT", "3306");
        String name = env("DB_NAME", "railway");  // matches Railway.app default
        String url  = "jdbc:mysql://" + host + ":" + port + "/" + name
                    + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";

        props.put("jakarta.persistence.jdbc.url",      url);
        props.put("jakarta.persistence.jdbc.user",     user);
        props.put("jakarta.persistence.jdbc.password", pass);
        return props;
    }

    private static void logResolvedDatabase(Map<String, Object> overrides) {
        String url = (String) overrides.get("jakarta.persistence.jdbc.url");
        if (url != null) {
            log.info("Using database from environment override: " + url);
        } else {
            log.info("Using database from persistence.xml fallback configuration.");
        }
    }

    private static String env(String key, String defaultValue) {
        // Check Java system property first (-DKEY=value), then OS env var
        String v = System.getProperty(key);
        if (v == null || v.isBlank()) v = System.getenv(key);
        return (v != null && !v.isBlank()) ? v : defaultValue;
    }

    private static String requiredEnv(String key) {
        String value = env(key, null);
        if (value == null) {
            throw new IllegalStateException("Missing required database environment variable: " + key);
        }
        return value;
    }

    public static void close() {
        if (emf != null && emf.isOpen()) {
            emf.close();
        }
    }
}
