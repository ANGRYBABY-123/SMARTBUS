package com.smartbus.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;

/**
 * Firebase Cloud Messaging stub — push notifications disabled.
 * Firebase Admin SDK dependency removed to simplify local build.
 * All methods are no-ops; the app starts and runs without Firebase credentials.
 */
public final class FirebaseUtil {

    private static final Logger log = LoggerFactory.getLogger(FirebaseUtil.class);

    private static final Map<Long, String> tokenStore = new ConcurrentHashMap<>();

    private FirebaseUtil() {}

    public static synchronized void initialize() {
        log.info("FirebaseUtil: push notifications disabled (stub mode).");
    }

    public static void registerToken(long userId, String fcmToken) {
        if (fcmToken != null && !fcmToken.isBlank()) {
            tokenStore.put(userId, fcmToken.trim());
        }
    }

    public static void removeToken(long userId) {
        tokenStore.remove(userId);
    }

    public static void sendToUser(long userId, String title, String body) {}

    public static void sendToUser(long userId, String title, String body,
                                  String clickUrl, String tag) {}

    public static void broadcastToAll(String title, String body, String clickUrl, String tag) {}

    public static void sendToUsers(Iterable<Long> userIds, String title, String body,
                                   String clickUrl, String tag) {}

    public static boolean isInitialized() { return false; }
}
