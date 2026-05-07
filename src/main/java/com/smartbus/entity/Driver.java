package com.smartbus.entity;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "drivers")
@PrimaryKeyJoinColumn(name = "driver_id")
public class Driver extends User {

    @Column(name = "registration_number", nullable = false, unique = true, length = 50)
    private String registrationNumber;

    @OneToMany(mappedBy = "driver", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Trip> trips;

    public Driver() {
        super();
        setRole("DRIVER");
    }

    public Driver(String name, String email, String password, String registrationNumber) {
        super(name, email, password, "DRIVER");
        this.registrationNumber = registrationNumber;
    }

    public String getRegistrationNumber() { return registrationNumber; }
    public void setRegistrationNumber(String registrationNumber) { this.registrationNumber = registrationNumber; }
    public List<Trip> getTrips() { return trips; }
    public void setTrips(List<Trip> trips) { this.trips = trips; }
}
