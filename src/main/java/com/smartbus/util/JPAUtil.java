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
     * Set on the application-server PC before starting Tomcat:
     *   DB_HOST  – IP or hostname of the MySQL server (default: localhost)
     *   DB_PORT  – MySQL port                          (default: 3306)
     *   DB_NAME  – Schema name                         (default: smartbus)
     *   DB_USER  – DB username                         (default: root)
     *   DB_PASS  – DB password                         (default: M@sydo123)
     */
    private static Map<String, Object> buildOverrides() {
        Map<String, Object> props = new HashMap<>();

        String host = env("DB_HOST", "localhost");
        String port = env("DB_PORT", "3306");
        String name = env("DB_NAME", "smartbus");
        String user = env("DB_USER", "root");
        String pass = env("DB_PASS", "M@sydo123");

        String url = "jdbc:mysql://" + host + ":" + port + "/" + name
                   + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";

        props.put("jakarta.persistence.jdbc.url",      url);
        props.put("jakarta.persistence.jdbc.user",     user);
        props.put("jakarta.persistence.jdbc.password", pass);
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
