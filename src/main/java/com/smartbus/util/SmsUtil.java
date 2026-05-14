package com.smartbus.util;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/**
 * Utility for sending SMS via Africa's Talking.
 *
 * Required environment variables (set in Render dashboard):
 *   AT_API_KEY    – Africa's Talking API key
 *   AT_USERNAME   – Africa's Talking account username (use "sandbox" for testing)
 *   AT_SENDER_ID  – Optional sender name/shortcode (e.g. CommuteSafe); leave blank if not registered
 */
public final class SmsUtil {

    // Use sandbox URL when AT_USERNAME is "sandbox"
    private static final String PROD_URL    = "https://api.africastalking.com/version1/messaging";
    private static final String SANDBOX_URL = "https://api.sandbox.africastalking.com/version1/messaging";

    private SmsUtil() {}

    private static String env(String key) {
        String v = System.getenv(key);
        if (v == null || v.isBlank()) {
            throw new IllegalStateException("Environment variable not set: " + key);
        }
        return v;
    }

    /**
     * Sends a 6-digit OTP SMS to the given phone number.
     *
     * @param toPhone E.164 format, e.g. "+27821234567"
     * @param otp     The 6-digit code to include in the message
     * @throws Exception on HTTP or API error
     */
    public static void sendOtp(String toPhone, String otp) throws Exception {
        String apiKey   = env("AT_API_KEY");
        String username = env("AT_USERNAME");
        String sender   = System.getenv("AT_SENDER_ID"); // optional

        String apiUrl = "sandbox".equalsIgnoreCase(username) ? SANDBOX_URL : PROD_URL;

        StringBuilder bodyBuilder = new StringBuilder();
        bodyBuilder.append("username=").append(java.net.URLEncoder.encode(username, "UTF-8"));
        bodyBuilder.append("&to=").append(java.net.URLEncoder.encode(toPhone, "UTF-8"));
        bodyBuilder.append("&message=").append(java.net.URLEncoder.encode(
                "Your CommuteSafe verification code is: " + otp + ". Valid for 10 minutes. Do not share this code.", "UTF-8"));
        if (sender != null && !sender.isBlank()) {
            bodyBuilder.append("&from=").append(java.net.URLEncoder.encode(sender.trim(), "UTF-8"));
        }

        String body = bodyBuilder.toString();

        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setConnectTimeout(10_000);
        conn.setReadTimeout(10_000);
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("apiKey", apiKey);
        conn.setRequestProperty("Accept", "application/json");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();
        if (status < 200 || status >= 300) {
            throw new RuntimeException("Africa's Talking SMS failed with HTTP " + status);
        }

        // Check response body for failure status
        String response = new String(conn.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
        if (response.contains("\"status\":\"Failed\"") || response.contains("\"status\": \"Failed\"")) {
            throw new RuntimeException("Africa's Talking SMS rejected: " + response);
        }
    }
}
