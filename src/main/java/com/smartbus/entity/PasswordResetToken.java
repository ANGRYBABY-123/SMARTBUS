package com.smartbus.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "password_reset_token")
public class PasswordResetToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** FK to users.user_id — stored as a plain Long so we avoid circular cascade. */
    @Column(name = "user_id", nullable = false)
    private Long userId;

    /** 64-char hex token (32 random bytes). */
    @Column(name = "token", nullable = false, unique = true, length = 64)
    private String token;

    /** Token expires 15 minutes after creation. */
    @Column(name = "expiry", nullable = false)
    private LocalDateTime expiry;

    public PasswordResetToken() {}

    public PasswordResetToken(Long userId, String token, LocalDateTime expiry) {
        this.userId = userId;
        this.token  = token;
        this.expiry = expiry;
    }

    public Long getId()                    { return id; }
    public Long getUserId()                { return userId; }
    public String getToken()               { return token; }
    public LocalDateTime getExpiry()       { return expiry; }

    public void setId(Long id)             { this.id = id; }
    public void setUserId(Long userId)     { this.userId = userId; }
    public void setToken(String token)     { this.token = token; }
    public void setExpiry(LocalDateTime e) { this.expiry = e; }
}
