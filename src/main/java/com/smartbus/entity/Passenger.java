package com.smartbus.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "passenger")
@PrimaryKeyJoinColumn(name = "passenger_id")
public class Passenger extends User {

    @Column(name = "email", insertable = false, updatable = false)
    private String passengerEmail;

    public Passenger() {
        super();
        setRole("PASSENGER");
    }

    public Passenger(String name, String email, String password) {
        super(name, email, password, "PASSENGER");
        this.passengerEmail = email;
    }

    public String getPassengerEmail() { return passengerEmail; }
    public void setPassengerEmail(String passengerEmail) { this.passengerEmail = passengerEmail; }
}
