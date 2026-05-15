package com.smartbus.util;

import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import java.util.HashMap;
import java.util.Map;

public class JPAUtil {

    private static final String PERSISTENCE_UNIT = "SmartBusPU";
    private static EntityManagerFactory emf;

    private JPAUtil() {}

    public static EntityManagerFactory getEntityManagerFactory() {
        if (emf == null || !emf.isOpen()) {
            emf = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT, buildOverrides());
        }
        return emf;
    }

    /**
     * Reads optional environment variables so the same WAR can connect to any
     * database server without recompiling.
     *
     * Only the properties whose env vars are explicitly set are overridden;
     * everything else falls through to the values in persistence.xml so the
     * app works out-of-the-box without any environment configuration.
     *
     * Set on the application-server / Render env vars:
     *   DB_HOST  – IP or hostname of the MySQL server
     *   DB_PORT  – MySQL port                          (default: 3306)
     *   DB_NAME  – Schema / database name
     *   DB_USER  – DB username
     *   DB_PASS  – DB password
     */
    private static Map<String, Object> buildOverrides() {
        Map<String, Object> props = new HashMap<>();

        String host = env("DB_HOST", null);
        // Only build a URL override when DB_HOST is explicitly supplied.
        // Without it, fall through to the jdbc.url in persistence.xml.
        if (host != null) {
            String port = env("DB_PORT", "3306");
            String name = env("DB_NAME", "smartbus");
            String url  = "jdbc:mysql://" + host + ":" + port + "/" + name
                        + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
            props.put("jakarta.persistence.jdbc.url", url);
        }

        String user = env("DB_USER", null);
        if (user != null) props.put("jakarta.persistence.jdbc.user", user);

        String pass = env("DB_PASS", null);
        if (pass != null) props.put("jakarta.persistence.jdbc.password", pass);

        return props;
    }

    private static String env(String key, String defaultValue) {
        // Check Java system property first (-DKEY=value), then OS env var
        String v = System.getProperty(key);
        if (v == null || v.isBlank()) v = System.getenv(key);
        return (v != null && !v.isBlank()) ? v : defaultValue;
    }

    public static void close() {
        if (emf != null && emf.isOpen()) {
            emf.close();
        }
    }
}
