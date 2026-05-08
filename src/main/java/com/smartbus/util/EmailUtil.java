package com.smartbus.util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

/**
 * Utility for sending transactional emails via SMTP.
 *
 * Required environment variables (set on Render / Railway):
 *   SMTP_HOST  – SMTP server hostname        (default: smtp.gmail.com)
 *   SMTP_PORT  – SMTP port                   (default: 587)
 *   SMTP_USER  – Sender email address        (required)
 *   SMTP_PASS  – SMTP password / app password (required)
 *   APP_URL    – Base URL of the app         (default: https://smartbus-8tvd.onrender.com)
 */
public final class EmailUtil {

    private EmailUtil() {}

    private static String env(String key, String defaultValue) {
        String v = System.getenv(key);
        return (v != null && !v.isEmpty()) ? v : defaultValue;
    }

    public static void sendPasswordReset(String toEmail, String resetToken) throws MessagingException {
        String host    = env("SMTP_HOST", "smtp.gmail.com");
        int    port    = Integer.parseInt(env("SMTP_PORT", "587"));
        String user    = env("SMTP_USER", null);
        String pass    = env("SMTP_PASS", null);
        String appUrl  = env("APP_URL",  "https://smartbus-8tvd.onrender.com");

        if (user == null || pass == null) {
            throw new MessagingException("SMTP_USER / SMTP_PASS environment variables are not set.");
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            host);
        props.put("mail.smtp.port",            String.valueOf(port));
        props.put("mail.smtp.ssl.trust",       host);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(user, pass);
            }
        });

        String resetLink = appUrl + "/reset-password?token=" + resetToken;

        Message msg = new MimeMessage(session);
        try {
            msg.setFrom(new InternetAddress(user, "SmartBus", "UTF-8"));
        } catch (java.io.UnsupportedEncodingException e) {
            msg.setFrom(new InternetAddress(user));
        }
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        msg.setSubject("SmartBus – Reset Your Password");
        msg.setContent(buildHtml(resetLink), "text/html; charset=UTF-8");

        Transport.send(msg);
    }

    private static String buildHtml(String resetLink) {
        return "<!DOCTYPE html><html><body style='font-family:Segoe UI,sans-serif;background:#f4f7fb;padding:32px'>"
             + "<div style='max-width:480px;margin:0 auto;background:#fff;border-radius:16px;padding:32px;box-shadow:0 4px 20px rgba(0,0,0,.08)'>"
             + "<h2 style='color:#000;margin-top:0'><span style='color:#00c853'>Smart</span>Bus – Password Reset</h2>"
             + "<p style='color:#555;font-size:.95rem'>We received a request to reset the password for your SmartBus account.</p>"
             + "<p style='color:#555;font-size:.95rem'>Click the button below to choose a new password. "
             + "This link is valid for <strong>15 minutes</strong>.</p>"
             + "<div style='text-align:center;margin:28px 0'>"
             + "<a href='" + resetLink + "' style='background:#000;color:#fff;text-decoration:none;"
             + "border-radius:10px;padding:13px 32px;font-weight:700;font-size:.95rem;display:inline-block'>"
             + "Reset Password</a></div>"
             + "<p style='color:#999;font-size:.8rem;margin-bottom:0'>"
             + "If you didn't request a password reset, you can safely ignore this email. "
             + "Your password will not be changed.</p>"
             + "<hr style='border:none;border-top:1px solid #eee;margin:20px 0'>"
             + "<p style='color:#bbb;font-size:.75rem;margin:0'>SmartBus &mdash; Real-time bus tracking system</p>"
             + "</div></body></html>";
    }
}
