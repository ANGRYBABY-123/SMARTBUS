package com.smartbus.servlet;

import com.smartbus.dao.GpsTrackingDAO;
import com.smartbus.dao.NotificationDAO;
import com.smartbus.dao.TripDAO;
import com.smartbus.entity.GpsTracking;
import com.smartbus.entity.Notification;
import com.smartbus.entity.Trip;
import com.smartbus.entity.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * AI endpoints:
 *   POST /ai/chat        — Gemini-powered chat assistant
 *   GET  /ai/eta         — Speed & traffic status from GPS trail
 *   GET  /ai/delay-risk  — Delay prediction + auto-notification
 */
@WebServlet("/ai/*")
public class AiServlet extends HttpServlet {

    private static final String GEMINI_KEY = "AIzaSyAMMxrYl49Xij4srs-sVjOmEv8Jq3BeJaw";
    private static final String GEMINI_URL =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=" + GEMINI_KEY;

    private static final Pattern TEXT_PAT =
        Pattern.compile("\"text\":\\s*\"((?:[^\"\\\\]|\\\\.)*)\"");

    private final TripDAO        tripDAO  = new TripDAO();
    private final GpsTrackingDAO gpsDAO   = new GpsTrackingDAO();
    private final NotificationDAO notifDAO = new NotificationDAO();

    // ── GET ──────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String path = req.getPathInfo();
        if (path == null) path = "/";
        switch (path) {
            case "/eta":        getEta(req, out);        break;
            case "/delay-risk": getDelayRisk(req, out);  break;
            default:            out.print("{}");
        }
    }

    // ── POST ─────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String path = req.getPathInfo();
        if ("/chat".equals(path)) {
            handleChat(req, out);
        } else {
            out.print("{\"error\":\"unknown endpoint\"}");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  /ai/chat  — Gemini assistant
    // ─────────────────────────────────────────────────────────────────────────
    private void handleChat(HttpServletRequest req, PrintWriter out) {
        User user = (User) req.getSession().getAttribute("loggedUser");
        if (user == null) { out.print("{\"error\":\"Not authenticated\"}"); return; }

        String question = req.getParameter("message");
        if (question == null || question.trim().isEmpty()) {
            out.print("{\"error\":\"Empty message\"}"); return;
        }
        question = question.trim();
        if (question.length() > 500) question = question.substring(0, 500);

        Trip trip = null;
        String tripIdStr = req.getParameter("tripId");
        if (tripIdStr != null) {
            try { trip = tripDAO.findByIdWithDetails(Long.parseLong(tripIdStr)); }
            catch (Exception ignored) {}
        }

        String prompt = buildChatPrompt(trip, question);
        String reply  = callGemini(prompt);
        out.print("{\"reply\":" + jsonString(reply) + "}");
    }

    private String buildChatPrompt(Trip trip, String question) {
        StringBuilder sb = new StringBuilder();
        sb.append("You are SmartBus AI, a helpful assistant for bus passengers. ");
        if (trip != null) {
            sb.append("The passenger is currently tracking route '")
              .append(trip.getRoute().getRouteName())
              .append("' from '").append(trip.getRoute().getStartLocation())
              .append("' to '").append(trip.getRoute().getEndLocation())
              .append("'. Driver: ").append(trip.getDriver().getName())
              .append(". Bus: ").append(trip.getBus().getRegistrationNumber())
              .append(". Trip status: ").append(trip.getStatus()).append(". ");
        }
        sb.append("Keep your reply to 2-3 sentences. Only answer questions related to the bus journey, transport, or travel. ");
        sb.append("Passenger question: ").append(question);
        return sb.toString();
    }

    private String callGemini(String prompt) {
        try {
            String body = "{\"contents\":[{\"parts\":[{\"text\":" + jsonString(prompt) + "}]}]}";
            URL url = URI.create(GEMINI_URL).toURL();
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(20000);
            conn.setDoOutput(true);
            try (OutputStream os = conn.getOutputStream()) {
                os.write(body.getBytes(StandardCharsets.UTF_8));
            }
            int code = conn.getResponseCode();
            InputStream is = (conn.getErrorStream() != null) ? conn.getErrorStream() : conn.getInputStream();
            String response = new String(is.readAllBytes(), StandardCharsets.UTF_8);
            if (code >= 400) {
                // Surface a readable hint from the Gemini error body
                java.util.regex.Matcher em = java.util.regex.Pattern
                    .compile("\"message\":\\s*\"([^\"]{1,120})")
                    .matcher(response);
                String hint = em.find() ? em.group(1) : ("HTTP " + code);
                return "AI unavailable: " + hint + ". Please try again later.";
            }
            Matcher m = TEXT_PAT.matcher(response);
            if (m.find()) {
                return m.group(1)
                    .replace("\\n", "\n").replace("\\\"", "\"")
                    .replace("\\\\", "\\").replace("\\t", " ");
            }
            return "I'm having trouble responding right now. Please try again shortly.";
        } catch (java.net.SocketTimeoutException e) {
            return "AI response timed out. Please try again.";
        } catch (Exception e) {
            return "AI service is temporarily unavailable (" + e.getClass().getSimpleName() + "). Please try again later.";
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  /ai/eta  — Current speed & traffic status from last GPS points
    // ─────────────────────────────────────────────────────────────────────────
    private void getEta(HttpServletRequest req, PrintWriter out) {
        try {
            long tripId = Long.parseLong(req.getParameter("tripId"));
            List<GpsTracking> pts = gpsDAO.findRecentByTrip(tripId, 10);
            if (pts.size() < 2) {
                out.print("{\"speedKmh\":0,\"status\":\"waiting\",\"label\":\"Waiting for GPS\",\"etaMinutes\":-1,\"distKm\":-1}");
                return;
            }
            double totalDist = 0, totalSecs = 0;
            for (int i = 1; i < pts.size(); i++) {
                GpsTracking a = pts.get(i-1), b = pts.get(i);
                totalDist += haversine(a.getLatitude(), a.getLongitude(), b.getLatitude(), b.getLongitude());
                totalSecs += Math.max(1, ChronoUnit.SECONDS.between(a.getTimestamp(), b.getTimestamp()));
            }
            double speedKmh = (totalDist / totalSecs) * 3.6;
            String status, label;
            if      (speedKmh < 2)  { status = "stalled"; label = "Stalled"; }
            else if (speedKmh < 12) { status = "slow";    label = "Slow traffic"; }
            else if (speedKmh < 45) { status = "normal";  label = "Moving normally"; }
            else                    { status = "fast";     label = "Moving fast"; }

            // Distance remaining to route end and ETA
            double distKm = -1;
            double etaMinutes = -1;
            Trip trip = tripDAO.findByIdWithDetails(tripId);
            if (trip != null && trip.getRoute().getEndLat() != null && trip.getRoute().getEndLng() != null) {
                GpsTracking lastPt = pts.get(pts.size() - 1);
                distKm = haversine(lastPt.getLatitude(), lastPt.getLongitude(),
                                   trip.getRoute().getEndLat(), trip.getRoute().getEndLng());
                double effectiveSpeed = Math.max(speedKmh, 5); // avoid division by zero / huge ETA
                etaMinutes = (distKm / effectiveSpeed) * 60;
            }

            out.print(String.format(
                "{\"speedKmh\":%.1f,\"status\":\"%s\",\"label\":\"%s\",\"etaMinutes\":%.0f,\"distKm\":%.2f}",
                speedKmh, status, label, etaMinutes, distKm));
        } catch (Exception e) {
            out.print("{\"speedKmh\":0,\"status\":\"error\",\"label\":\"--\",\"etaMinutes\":-1,\"distKm\":-1}");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  /ai/delay-risk  — Predictive delay detection + auto-notification
    // ─────────────────────────────────────────────────────────────────────────
    private void getDelayRisk(HttpServletRequest req, PrintWriter out) {
        try {
            long tripId = Long.parseLong(req.getParameter("tripId"));
            List<GpsTracking> pts = gpsDAO.findRecentByTrip(tripId, 12);

            if (pts.size() < 3) {
                out.print("{\"risk\":\"UNKNOWN\",\"confidence\":0,\"message\":\"Not enough GPS data yet.\"}");
                return;
            }

            // Build speed array (km/h) for each consecutive pair
            double[] speeds = new double[pts.size() - 1];
            for (int i = 1; i < pts.size(); i++) {
                GpsTracking a = pts.get(i-1), b = pts.get(i);
                double dist = haversine(a.getLatitude(), a.getLongitude(), b.getLatitude(), b.getLongitude());
                double secs = Math.max(1, ChronoUnit.SECONDS.between(a.getTimestamp(), b.getTimestamp()));
                speeds[i-1] = (dist / secs) * 3.6;
            }

            // Overall average speed
            double avgSpeedSum = 0;
            for (double s : speeds) avgSpeedSum += s;
            double avgSpeed = avgSpeedSum / speeds.length;

            // Recent speed: last 3 intervals
            int n = speeds.length;
            double recentAvg = (speeds[n-1]
                + (n > 1 ? speeds[n-2] : speeds[n-1])
                + (n > 2 ? speeds[n-3] : speeds[n-1])) / 3.0;

            // Count slow intervals
            int slowCount = 0;
            for (double s : speeds) if (s < 5) slowCount++;

            // Classify risk
            String risk; String message; int confidence;
            if (recentAvg < 2 && slowCount >= 3) {
                risk = "HIGH"; confidence = 92;
                message = "Bus appears stalled. Significant delay expected.";
            } else if (recentAvg < 8 && slowCount >= 4) {
                risk = "HIGH"; confidence = 81;
                message = "Heavy traffic detected. Expect delays on this route.";
            } else if (recentAvg < 15 && slowCount >= 3) {
                risk = "MEDIUM"; confidence = 63;
                message = "Slow traffic conditions. Minor delay possible.";
            } else if (avgSpeed > 5 && recentAvg < avgSpeed * 0.45) {
                risk = "MEDIUM"; confidence = 57;
                message = "Speed dropping significantly. Possible congestion ahead.";
            } else {
                risk = "LOW"; confidence = 88;
                message = "Bus on schedule. No delays predicted.";
            }

            // Auto-notify passengers if risk is not LOW and no recent AI alert exists
            if (!"LOW".equals(risk) && !notifDAO.hasRecentNotifOfType(tripId, "AI_DELAY", 10)) {
                Trip trip = tripDAO.findByIdWithDetails(tripId);
                if (trip != null) {
                    String notifMsg = "🤖 AI Prediction: " + message
                        + " (Route: " + trip.getRoute().getRouteName() + ", "
                        + trip.getRoute().getStartLocation() + " → "
                        + trip.getRoute().getEndLocation() + ")";
                    notifDAO.save(new Notification(
                        trip.getDriver(), trip, notifMsg, "AI_DELAY", LocalDateTime.now()));
                }
            }

            out.print(String.format(
                "{\"risk\":\"%s\",\"confidence\":%d,\"message\":\"%s\",\"speedKmh\":%.1f}",
                risk, confidence, escJson(message), recentAvg));

        } catch (Exception e) {
            out.print("{\"risk\":\"UNKNOWN\",\"confidence\":0,\"message\":\"Analysis error.\"}");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  Helpers
    // ─────────────────────────────────────────────────────────────────────────
    private double haversine(double lat1, double lon1, double lat2, double lon2) {
        final double R = 6371000;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat/2)*Math.sin(dLat/2)
                 + Math.cos(Math.toRadians(lat1))*Math.cos(Math.toRadians(lat2))
                 * Math.sin(dLon/2)*Math.sin(dLon/2);
        return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    }

    private String jsonString(String s) {
        if (s == null) return "\"\"";
        return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"")
                        .replace("\n", "\\n").replace("\r", "").replace("\t", " ") + "\"";
    }

    private String escJson(String s) {
        return s == null ? "" : s.replace("\\","\\\\").replace("\"","\\\"")
                                  .replace("\n","\\n").replace("\r","");
    }
}
