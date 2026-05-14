package com.smartbus.util;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

/**
 * Utility for Twilio Verify v2 (SMS OTP).
 *
 * Required environment variables (set in Render dashboard):
 *   TWILIO_ACCOUNT_SID   – your Twilio Account SID
 *   TWILIO_AUTH_TOKEN    – your Twilio Auth Token
 *   TWILIO_VERIFY_SID    – Verify Service SID (starts with VA...)
 */
public final class TwilioUtil {

    private static final String BASE_URL = "https://verify.twilio.com/v2/Services/";

    private TwilioUtil() {}

    private static String env(String key) {
        String v = System.getenv(key);
        if (v == null || v.isBlank()) {
            throw new IllegalStateException("Environment variable not set: " + key);
        }
        return v;
    }

    /**
     * Starts a Twilio Verify SMS verification for the given phone number.
     *
     * @param toPhone E.164 format, e.g. "+27821234567"
     * @throws Exception on HTTP or API error
     */
    public static void sendVerification(String toPhone) throws Exception {
        String accountSid = env("TWILIO_ACCOUNT_SID");
        String authToken  = env("TWILIO_AUTH_TOKEN");
        String verifySid  = env("TWILIO_VERIFY_SID");

        String url  = BASE_URL + verifySid + "/Verifications";
        String body = "To=" + java.net.URLEncoder.encode(toPhone, "UTF-8") + "&Channel=sms";

        int status = post(url, accountSid, authToken, body);
        if (status < 200 || status >= 300) {
            throw new RuntimeException("Twilio Verify start failed with HTTP " + status);
        }
    }

    /**
     * Checks a verification code submitted by the user.
     *
     * @param toPhone E.164 format
     * @param code    The 6-digit code entered by the user
     * @return true if the code is correct and approved by Twilio
     * @throws Exception on HTTP or API error
     */
    public static boolean checkVerification(String toPhone, String code) throws Exception {
        if (code == null || code.isBlank()) return false;

        String accountSid = env("TWILIO_ACCOUNT_SID");
        String authToken  = env("TWILIO_AUTH_TOKEN");
        String verifySid  = env("TWILIO_VERIFY_SID");

        String url  = BASE_URL + verifySid + "/VerificationCheck";
        String body = "To=" + java.net.URLEncoder.encode(toPhone, "UTF-8")
                    + "&Code=" + java.net.URLEncoder.encode(code.trim(), "UTF-8");

        HttpURLConnection conn = openConnection(url, accountSid, authToken);
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }

        int httpStatus = conn.getResponseCode();
        if (httpStatus < 200 || httpStatus >= 300) {
            return false; // expired / wrong code returns 404 from Twilio
        }

        // Read response body and look for "approved"
        String response = new String(conn.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
        return response.contains("\"status\":\"approved\"");
    }

    // ── helpers ──────────────────────────────────────────────────────────────

    private static int post(String urlStr, String accountSid, String authToken, String body) throws Exception {
        HttpURLConnection conn = openConnection(urlStr, accountSid, authToken);
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }
        return conn.getResponseCode();
    }

    private static HttpURLConnection openConnection(String urlStr, String accountSid, String authToken)
            throws Exception {
        URL url = new URL(urlStr);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setConnectTimeout(10_000);
        conn.setReadTimeout(10_000);

        String credentials = Base64.getEncoder()
                .encodeToString((accountSid + ":" + authToken).getBytes(StandardCharsets.UTF_8));
        conn.setRequestProperty("Authorization", "Basic " + credentials);
        return conn;
    }
}
