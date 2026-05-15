package com.smartbus.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;

@Entity
@Table(name = "user")
@Inheritance(strategy = InheritanceType.JOINED)
@NamedQueries({
    @NamedQuery(
        name  = "User.findByEmail",
        query = "SELECT u FROM User u WHERE u.email = :email"),
    @NamedQuery(
        name  = "User.findByRole",
        query = "SELECT u FROM User u WHERE u.role = :role ORDER BY u.name"),
    @NamedQuery(
        name  = "User.findByStatus",
        query = "SELECT u FROM User u WHERE u.status = :status ORDER BY u.userId DESC"),
    @NamedQuery(
        name  = "User.findByGoogleId",
        query = "SELECT u FROM User u WHERE u.googleId = :googleId"),
    @NamedQuery(
        name  = "User.countByEmail",
        query = "SELECT COUNT(u) FROM User u WHERE u.email = :email"),
    @NamedQuery(
        name  = "User.searchByName",
        query = "SELECT u FROM User u WHERE LOWER(u.name) LIKE :name AND u.status <> 'PENDING_REMOVAL' ORDER BY u.name")
})
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long userId;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "email", nullable = false, unique = true, length = 150)
    private String email;

    @Column(name = "password", nullable = false, length = 255)
    private String password;

    @Column(name = "role", nullable = false, length = 20)
    private String role;

    @Column(name = "status", nullable = false, columnDefinition = "VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'")
    private String status = "ACTIVE";

    @Column(name = "google_id", length = 100, unique = true)
    private String googleId;

    @Column(name = "phone_number", length = 20)
    private String phoneNumber;

    @Column(name = "removal_scheduled_at")
    private LocalDateTime removalScheduledAt;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Notification> notifications;

    public User() {}

    public User(String name, String email, String password, String role) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
    }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getGoogleId() { return googleId; }
    public void setGoogleId(String googleId) { this.googleId = googleId; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public LocalDateTime getRemovalScheduledAt() { return removalScheduledAt; }
    public void setRemovalScheduledAt(LocalDateTime removalScheduledAt) { this.removalScheduledAt = removalScheduledAt; }
    /** Epoch-milliseconds when the 30-minute removal window closes; 0 if not scheduled. */
    public long getRemovalDeadlineEpochMillis() {
        if (removalScheduledAt == null) return 0;
        return removalScheduledAt.plusMinutes(30).atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
    }
    public List<Notification> getNotifications() { return notifications; }
    public void setNotifications(List<Notification> notifications) { this.notifications = notifications; }
}
