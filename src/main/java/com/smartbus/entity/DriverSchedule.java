package com.smartbus.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "driver_schedule")
public class DriverSchedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ds_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id", nullable = false)
    private Driver driver;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_id", nullable = false)
    private Bus bus;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "route_id", nullable = false)
    private Route route;

    /** Morning / Afternoon / Shuttle */
    @Column(name = "shift_type", length = 20, nullable = false)
    private String shiftType;

    @Column(name = "shift_start", nullable = false)
    private LocalTime shiftStart;

    @Column(name = "shift_end", nullable = false)
    private LocalTime shiftEnd;

    /** Always the Monday of the week this schedule applies to. */
    @Column(name = "week_start_date", nullable = false)
    private LocalDate weekStartDate;

    /** True once admin has published this entry (trips + notifications sent). */
    @Column(name = "published", nullable = false)
    private boolean published = false;

    public DriverSchedule() {}

    public DriverSchedule(Driver driver, Bus bus, Route route,
                          String shiftType, LocalTime shiftStart, LocalTime shiftEnd,
                          LocalDate weekStartDate) {
        this.driver = driver;
        this.bus = bus;
        this.route = route;
        this.shiftType = shiftType;
        this.shiftStart = shiftStart;
        this.shiftEnd = shiftEnd;
        this.weekStartDate = weekStartDate;
        this.published = false;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Driver getDriver() { return driver; }
    public void setDriver(Driver driver) { this.driver = driver; }
    public Bus getBus() { return bus; }
    public void setBus(Bus bus) { this.bus = bus; }
    public Route getRoute() { return route; }
    public void setRoute(Route route) { this.route = route; }
    public String getShiftType() { return shiftType; }
    public void setShiftType(String shiftType) { this.shiftType = shiftType; }
    public LocalTime getShiftStart() { return shiftStart; }
    public void setShiftStart(LocalTime shiftStart) { this.shiftStart = shiftStart; }
    public LocalTime getShiftEnd() { return shiftEnd; }
    public void setShiftEnd(LocalTime shiftEnd) { this.shiftEnd = shiftEnd; }
    public LocalDate getWeekStartDate() { return weekStartDate; }
    public void setWeekStartDate(LocalDate weekStartDate) { this.weekStartDate = weekStartDate; }
    public boolean isPublished() { return published; }
    public void setPublished(boolean published) { this.published = published; }
}
