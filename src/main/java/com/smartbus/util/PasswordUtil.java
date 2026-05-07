package com.smartbus.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utility for BCrypt password hashing and verification.
 * Includes backward-compatible verification for accounts that still hold
 * plain-text passwords from before BCrypt was introduced.
 */
public final class PasswordUtil {

    private static final int WORK_FACTOR = 12;

    private PasswordUtil() {}

    /** Hash a plain-text password with BCrypt (work factor 12). */
    public static String hash(String plainPassword) {
        if (plainPassword == null) throw new IllegalArgumentException("Password must not be null");
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(WORK_FACTOR));
    }

    /**
     * Verify a plain-text password against a stored value.
     * If the stored value is not a BCrypt hash (legacy migration path),
     * falls back to plain-text equality so existing accounts still work.
     */
    public static boolean verify(String plainPassword, String storedPassword) {
        if (plainPassword == null || storedPassword == null) return false;
        if (isHashed(storedPassword)) {
            return BCrypt.checkpw(plainPassword, storedPassword);
        }
        // Legacy plain-text — constant-time comparison to resist timing attacks
        return constantTimeEquals(plainPassword, storedPassword);
    }

    /** Returns true if the stored value looks like a BCrypt hash. */
    public static boolean isHashed(String password) {
        return password != null
                && (password.startsWith("$2a$") || password.startsWith("$2b$") || password.startsWith("$2y$"));
    }

    /** Constant-time string comparison to prevent timing-based enumeration. */
    private static boolean constantTimeEquals(String a, String b) {
        if (a.length() != b.length()) return false;
        int diff = 0;
        for (int i = 0; i < a.length(); i++) {
            diff |= a.charAt(i) ^ b.charAt(i);
        }
        return diff == 0;
    }
}
