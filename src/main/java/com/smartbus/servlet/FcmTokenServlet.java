package com.smartbus.servlet;

import com.smartbus.entity.User;
import com.smartbus.util.FirebaseUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Receives and stores a browser's FCM registration token so the server can
 * send push notifications to that device.
 *
 * POST /fcm/token
 *   token  – the FCM web-push token string obtained by the client via
 *             firebase.messaging().getToken({ vapidKey: '...' })
 *
 * Requires the user to be authenticated (checked via session).
 */
@WebServlet("/fcm/token")
public class FcmTokenServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");

        User user = (User) req.getSession(false) != null
                    ? (User) req.getSession(false).getAttribute("loggedUser")
                    : null;

        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().print("{\"ok\":false,\"error\":\"Not authenticated\"}");
            return;
        }

        String token = req.getParameter("token");
        if (token == null || token.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().print("{\"ok\":false,\"error\":\"Missing token\"}");
            return;
        }

        // Validate: FCM tokens are alphanumeric with hyphens/underscores/colons, typically 140–200 chars
        if (token.length() > 500 || !token.matches("[A-Za-z0-9\\-_:]+")) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().print("{\"ok\":false,\"error\":\"Invalid token format\"}");
            return;
        }

        FirebaseUtil.registerToken(user.getUserId(), token);
        resp.getWriter().print("{\"ok\":true}");
    }
}
