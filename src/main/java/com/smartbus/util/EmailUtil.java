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
 */
public final class EmailUtil {

    private EmailUtil() {}

    private static String env(String key, String defaultValue) {
        String v = System.getenv(key);
        return (v != null && !v.isEmpty()) ? v : defaultValue;
    }

    /**
     * Sends a 5-digit verification code to the given email address.
     */
    public static void sendPasswordResetCode(String toEmail, String code) throws MessagingException {
        String host = env("SMTP_HOST", "smtp.gmail.com");
        int    port = Integer.parseInt(env("SMTP_PORT", "587"));
        String user = env("SMTP_USER", null);
        String pass = env("SMTP_PASS", null);

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

        Message msg = new MimeMessage(session);
        try {
            msg.setFrom(new InternetAddress(user, "SmartBus", "UTF-8"));
        } catch (java.io.UnsupportedEncodingException e) {
            msg.setFrom(new InternetAddress(user));
        }
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        msg.setSubject("SmartBus – Your Password Reset Code");
        msg.setContent(buildCodeHtml(code), "text/html; charset=UTF-8");

        Transport.send(msg);
    }

    /**
     * Sends an account-approval notification to the newly activated user.
     */
    public static void sendApprovalEmail(String toEmail, String userName) throws MessagingException {
        String host = env("SMTP_HOST", "smtp.gmail.com");
        int    port = Integer.parseInt(env("SMTP_PORT", "587"));
        String user = env("SMTP_USER", null);
        String pass = env("SMTP_PASS", null);

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

        Message msg = new MimeMessage(session);
        try {
            msg.setFrom(new InternetAddress(user, "SmartBus", "UTF-8"));
        } catch (java.io.UnsupportedEncodingException e) {
            msg.setFrom(new InternetAddress(user));
        }
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        msg.setSubject("SmartBus – Your Account Has Been Approved");
        msg.setContent(buildApprovalHtml(userName), "text/html; charset=UTF-8");

        Transport.send(msg);
    }

    private static String buildApprovalHtml(String name) {
        return "<!DOCTYPE html><html><body style='font-family:Segoe UI,sans-serif;background:#f4f7fb;padding:32px'>"
             + "<div style='max-width:480px;margin:0 auto;background:#fff;border-radius:16px;padding:32px;box-shadow:0 4px 20px rgba(0,0,0,.08)'>"
             + "<h2 style='color:#000;margin-top:0'><span style='color:#00c853'>Smart</span>Bus – Account Approved</h2>"
             + "<p style='color:#555;font-size:.95rem'>Hi <strong>" + name + "</strong>,</p>"
             + "<p style='color:#555;font-size:.95rem'>Great news! Your SmartBus account has been <strong style='color:#00c853'>approved</strong> by our admin team.</p>"
             + "<p style='color:#555;font-size:.95rem'>You can now sign in and start using the platform.</p>"
             + "<div style='text-align:center;margin:28px 0'>"
             + "<a href='#' style='display:inline-block;background:#000;color:#fff;text-decoration:none;"
             + "border-radius:12px;padding:14px 36px;font-size:.95rem;font-weight:800;'>Sign In to SmartBus</a>"
             + "</div>"
             + "<p style='color:#999;font-size:.8rem;margin-bottom:0'>If you didn't create a SmartBus account, you can safely ignore this email.</p>"
             + "<hr style='border:none;border-top:1px solid #eee;margin:20px 0'>"
             + "<p style='color:#bbb;font-size:.75rem;margin:0'>SmartBus &mdash; Real-time bus tracking system</p>"
             + "</div></body></html>";
    }

    private static String buildCodeHtml(String code) {
        // Format code with a space in the middle: "123 45"
        String display = code.substring(0, 3) + " " + code.substring(3);
        return "<!DOCTYPE html><html><body style='font-family:Segoe UI,sans-serif;background:#f4f7fb;padding:32px'>"
             + "<div style='max-width:480px;margin:0 auto;background:#fff;border-radius:16px;padding:32px;box-shadow:0 4px 20px rgba(0,0,0,.08)'>"
             + "<h2 style='color:#000;margin-top:0'><span style='color:#00c853'>Smart</span>Bus – Password Reset</h2>"
             + "<p style='color:#555;font-size:.95rem'>We received a request to reset your SmartBus password.</p>"
             + "<p style='color:#555;font-size:.95rem'>Enter the code below on the verification page. "
             + "This code is valid for <strong>15 minutes</strong>.</p>"
             + "<div style='text-align:center;margin:28px 0'>"
             + "<div style='display:inline-block;background:#f0f7ff;border:2px solid #bfdbfe;"
             + "border-radius:16px;padding:18px 40px'>"
             + "<div style='font-size:2.4rem;font-weight:900;letter-spacing:8px;color:#000'>" + display + "</div>"
             + "<div style='font-size:.75rem;color:#94a3b8;margin-top:6px'>Your 5-digit reset code</div>"
             + "</div></div>"
             + "<p style='color:#999;font-size:.8rem;margin-bottom:0'>"
             + "If you didn't request a password reset, you can safely ignore this email.</p>"
             + "<hr style='border:none;border-top:1px solid #eee;margin:20px 0'>"
             + "<p style='color:#bbb;font-size:.75rem;margin:0'>SmartBus &mdash; Real-time bus tracking system</p>"
             + "</div></body></html>";
    }
}
