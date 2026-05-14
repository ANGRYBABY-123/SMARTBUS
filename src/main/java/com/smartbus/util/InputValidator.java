package com.smartbus.util;

import java.util.regex.Pattern;

/**
 * Server-side input validation and sanitisation utilities.
 * All validation is performed after trimming whitespace.
 */
public final class InputValidator {

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$");

    private InputValidator() {}

    /** Valid email address according to RFC 5321 simplified pattern. */
    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^a-zA-Z0-9]).{8,}$");

    /** Password must be ≥8 chars and contain uppercase, lowercase, digit, and special character. */
    public static boolean isValidPassword(String password) {
        return password != null && PASSWORD_PATTERN.matcher(password).matches();
    }

    /** Name must be at least 2 non-whitespace characters. */
    public static boolean isValidName(String name) {
        return name != null && name.trim().length() >= 2;
    }

    /**
     * Returns true if any of the supplied fields is null or blank.
     * Use for mandatory-field checks.
     */
    public static boolean anyBlank(String... fields) {
        for (String f : fields) {
            if (f == null || f.trim().isEmpty()) return true;
        }
        return false;
    }

    /**
     * Light HTML escaping to prevent XSS when values are reflected back
     * into error messages or logs.  JSP / JSTL's c:out handles display-time
     * escaping; this is for values used in Java string concatenation.
     */
    public static String sanitize(String input) {
        if (input == null) return null;
        return input.trim()
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
}
