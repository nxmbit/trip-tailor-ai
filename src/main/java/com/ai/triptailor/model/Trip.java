package com.ai.triptailor.model;

import jakarta.persistence.*;

import java.util.Date;
import java.util.Set;

@Entity
public class Trip {
    @Id
    private Long id;

    private String imageFileName;

    private String destination;

    private String description;

    private Date tripStartDate;

    private Date tripEndDate;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @OneToMany(mappedBy = "trip", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<TripDay> tripDays;

    public Trip() {
    }

    public Trip(Long id, String imageFileName, String destination, String description, Date tripStartDate, Date tripEndDate, User user) {
        this.id = id;
        this.imageFileName = imageFileName;
        this.destination = destination;
        this.description = description;
        this.tripStartDate = tripStartDate;
        this.tripEndDate = tripEndDate;
        this.user = user;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getImageFileName() {
        return imageFileName;
    }

    public void setImageFileName(String imageUrl) {
        this.imageFileName = imageUrl;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public Date getTripStartDate() {
        return tripStartDate;
    }

    public void setTripStartDate(Date tripStartDate) {
        this.tripStartDate = tripStartDate;
    }

    public Date getTripEndDate() {
        return tripEndDate;
    }

    public void setTripEndDate(Date tripEndDate) {
        this.tripEndDate = tripEndDate;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Set<TripDay> getTripDays() {
        return tripDays;
    }

    public void setTripDays(Set<TripDay> tripDays) {
        this.tripDays = tripDays;
    }
}
