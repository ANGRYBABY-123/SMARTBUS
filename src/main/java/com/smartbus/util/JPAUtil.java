package com.smartbus.util;

import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class JPAUtil {

    private static final String PERSISTENCE_UNIT = "SmartBusPU";
    private static final Logger log = Logger.getLogger(JPAUtil.class.getName());
    private static final Pattern MYSQL_URL = Pattern.compile(
        "^(?:jdbc:)?mysql://(?:(?<user>[^:/@?#]+)(?::(?<pass>[^@/?#]*))?@)?(?<host>[^:/?#]+)(?::(?<port>\\d+))?/(?<db>[^?]+)(?:\\?(?<params>.*))?$"
    );
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
     * Reads environment variables so the same WAR can connect to Railway or
     * another MySQL server without recompiling.
     *
     * Preferred overrides, in order:
     *   1. DB_URL / MYSQL_PUBLIC_URL / MYSQL_URL (full MySQL URL)
     *   2. DB_HOST + DB_USER + DB_PASS (split credentials)
     *
     * If no override is present, the persistence.xml fallback is used.
     */
    private static Map<String, Object> buildOverrides() {
        Map<String, Object> props = new HashMap<>();

        String url = env("DB_URL", null);
        if (url == null) url = env("MYSQL_PUBLIC_URL", null);
        if (url == null) url = env("MYSQL_URL", null);

        if (url != null) {
            props.putAll(fromMysqlUrl(url));
            return props;
        }

        String host = requiredEnv("DB_HOST");
        String user = requiredEnv("DB_USER");
        String pass = requiredEnv("DB_PASS");

        String port    = env("DB_PORT", "3306");
        String name    = env("DB_NAME", "railway");
        String jdbcUrl = "jdbc:mysql://" + host + ":" + port + "/" + name
                       + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";

        props.put("jakarta.persistence.jdbc.url",      jdbcUrl);
        props.put("jakarta.persistence.jdbc.user",     user);
        props.put("jakarta.persistence.jdbc.password", pass);
        return props;
    }

    private static Map<String, Object> fromMysqlUrl(String rawUrl) {
        String url = rawUrl.trim();
        Matcher matcher = MYSQL_URL.matcher(url);
        if (!matcher.matches()) {
            throw new IllegalStateException("Invalid MySQL URL in DB_URL/MYSQL_PUBLIC_URL/MYSQL_URL");
        }

        String host = matcher.group("host");
        String port = matcher.group("port") != null ? matcher.group("port") : "3306";
        String db   = matcher.group("db");
        String params = matcher.group("params");
        String user = matcher.group("user");
        String pass = matcher.group("pass");

        String jdbcUrl = "jdbc:mysql://" + host + ":" + port + "/" + db;
        if (params != null && !params.isBlank()) {
            jdbcUrl += "?" + params;
        } else {
            jdbcUrl += "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
        }

        Map<String, Object> props = new HashMap<>();
        props.put("jakarta.persistence.jdbc.url", jdbcUrl);
        if (user != null && !user.isBlank()) {
            props.put("jakarta.persistence.jdbc.user", user);
        }
        if (pass != null && !pass.isBlank()) {
            props.put("jakarta.persistence.jdbc.password", pass);
        }
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
