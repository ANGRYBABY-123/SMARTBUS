package com.smartbus.entity;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "bus_stops")
public class BusStop {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "stop_id")
    private Long stopId;

    @Column(name = "stop_name", nullable = false, length = 150)
    private String name;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
    private Double longitude;

    /** Routes that serve this stop. BusStop owns the join table. */
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "stop_routes",
        joinColumns        = @JoinColumn(name = "stop_id"),
        inverseJoinColumns = @JoinColumn(name = "route_id")
    )
    private List<Route> routes = new ArrayList<>();

    public BusStop() {}

    public BusStop(String name, Double latitude, Double longitude) {
        this.name      = name;
        this.latitude  = latitude;
        this.longitude = longitude;
    }

    public Long   getStopId()              { return stopId; }
    public void   setStopId(Long stopId)   { this.stopId = stopId; }
    public String getName()                { return name; }
    public void   setName(String name)     { this.name = name; }
    public Double getLatitude()            { return latitude; }
    public void   setLatitude(Double lat)  { this.latitude = lat; }
    public Double getLongitude()           { return longitude; }
    public void   setLongitude(Double lng) { this.longitude = lng; }
    public List<Route> getRoutes()                    { return routes; }
    public void        setRoutes(List<Route> routes)  { this.routes = routes; }
}
