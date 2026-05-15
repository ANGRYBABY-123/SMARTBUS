package com.smartbus.util;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.google.firebase.messaging.WebpushConfig;
import com.google.firebase.messaging.WebpushNotification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;

/**
 * Firebase Cloud Messaging utility for sending browser push notifications.
 *
 * Initialisation (call once at startup from AppContextListener):
 *   FirebaseUtil.initialize();
 *
 * Required – one of:
 *   FIREBASE_SERVICE_ACCOUNT_JSON  env var containing the full service account JSON string
 *   FIREBASE_SERVICE_ACCOUNT_PATH  env var containing the path to the service account JSON file
 *
 * FCM token registration:
 *   Client calls POST /fcm/token with { token: "..." }
 *   Server stores token via FirebaseUtil.registerToken(userId, token)
 *
 * Sending a push notification:
 *   FirebaseUtil.sendToUser(userId, title, body, data)
 */
public final class FirebaseUtil {

    private static final Logger log = LoggerFactory.getLogger(FirebaseUtil.class);

    /** userId → FCM web-push token.  Populated when a browser tab registers. */
    private static final Map<Long, String> tokenStore = new ConcurrentHashMap<>();

    private static volatile boolean initialized = false;

    private FirebaseUtil() {}

    // ── Initialisation ────────────────────────────────────────────────────────

    public static synchronized void initialize() {
        if (initialized) return;
        try {
            // Check if already initialised (e.g., hot-reload)
            if (!FirebaseApp.getApps().isEmpty()) {
                initialized = true;
                return;
            }

            InputStream serviceAccount = resolveServiceAccount();
            if (serviceAccount == null) {
                log.warn("FirebaseUtil: no service account credentials found – push notifications disabled. "
                       + "Set FIREBASE_SERVICE_ACCOUNT_JSON or FIREBASE_SERVICE_ACCOUNT_PATH env var.");
                return;
            }

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();
            FirebaseApp.initializeApp(options);
            initialized = true;
            log.info("FirebaseUtil: Firebase Admin SDK initialised successfully.");
        } catch (Exception e) {
            log.error("FirebaseUtil: initialisation failed – push notifications disabled.", e);
        }
    }

    private static InputStream resolveServiceAccount() {
        // 1. Full JSON as env var (recommended for Render secrets)
        String json = System.getenv("FIREBASE_SERVICE_ACCOUNT_JSON");
        if (json != null && !json.isBlank()) {
            return new ByteArrayInputStream(json.trim().getBytes(StandardCharsets.UTF_8));
        }
        // 2. Path to JSON file
        String path = System.getenv("FIREBASE_SERVICE_ACCOUNT_PATH");
        if (path != null && !path.isBlank()) {
            try { return new FileInputStream(path.trim()); }
            catch (Exception e) { log.warn("FirebaseUtil: could not open service account file: {}", path); }
        }
        return null;
    }

    // ── Token management ──────────────────────────────────────────────────────

    public static void registerToken(long userId, String fcmToken) {
        if (fcmToken != null && !fcmToken.isBlank()) {
            tokenStore.put(userId, fcmToken.trim());
        }
    }

    public static void removeToken(long userId) {
        tokenStore.remove(userId);
    }

    // ── Send helpers ──────────────────────────────────────────────────────────

    /**
     * Send a push notification to a single user by their stored FCM token.
     * Silently skips if the user has no token or Firebase is not initialised.
     */
    public static void sendToUser(long userId, String title, String body) {
        sendToUser(userId, title, body, null, null);
    }

    public static void sendToUser(long userId, String title, String body,
                                  String clickUrl, String tag) {
        if (!initialized) return;
        String token = tokenStore.get(userId);
        if (token == null || token.isBlank()) return;
        sendToToken(token, title, body, clickUrl, tag);
    }

    /**
     * Broadcast to all registered tokens (e.g., delay alert for all passengers).
     */
    public static void broadcastToAll(String title, String body, String clickUrl, String tag) {
        if (!initialized || tokenStore.isEmpty()) return;
        tokenStore.forEach((uid, token) -> sendToToken(token, title, body, clickUrl, tag));
    }

    /**
     * Broadcast to all users whose userId is in the given set.
     */
    public static void sendToUsers(Iterable<Long> userIds, String title, String body,
                                   String clickUrl, String tag) {
        if (!initialized) return;
        for (Long uid : userIds) {
            String token = tokenStore.get(uid);
            if (token != null && !token.isBlank()) {
                sendToToken(token, title, body, clickUrl, tag);
            }
        }
    }

    private static void sendToToken(String token, String title, String body,
                                    String clickUrl, String tag) {
        try {
            WebpushNotification.Builder notifBuilder = WebpushNotification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .setIcon("/favicon.ico")
                    .setBadge("/favicon.ico");
            if (tag != null && !tag.isBlank()) {
                notifBuilder.setTag(tag);
            }

            WebpushConfig.Builder webpushBuilder = WebpushConfig.builder()
                    .setNotification(notifBuilder.build());
            if (clickUrl != null && !clickUrl.isBlank()) {
                webpushBuilder.putHeader("urgency", "high");
                webpushBuilder.putData("click_action", clickUrl);
            }

            Message message = Message.builder()
                    .setToken(token)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .setWebpushConfig(webpushBuilder.build())
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);
            log.debug("FCM sent: {}", response);
        } catch (Exception e) {
            log.warn("FCM send failed for token {}: {}", token.substring(0, Math.min(20, token.length())), e.getMessage());
        }
    }

    public static boolean isInitialized() { return initialized; }
}
