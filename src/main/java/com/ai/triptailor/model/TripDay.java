package com.ai.triptailor.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "trip_day")
public class TripDay {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Date date;
    private int dayNumber;
    private String description;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "trip_id", nullable = false)
    private Trip trip;

    @OneToMany(mappedBy = "tripDay", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<Attraction> attractions;

    public void addAttraction(Attraction attraction) {
        if (this.attractions == null) {
            this.attractions = new HashSet<>();
        }
        this.attractions.add(attraction);
        attraction.setTripDay(this);
    }

    public void removeAttraction(Attraction attraction) {
        if (this.attractions != null) {
            this.attractions.remove(attraction);
            attraction.setTripDay(null);
        }
    }

    public TripDay() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public int getDayNumber() {
        return dayNumber;
    }

    public void setDayNumber(int dayNumber) {
        this.dayNumber = dayNumber;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Trip getTrip() {
        return trip;
    }

    public void setTrip(Trip trip) {
        this.trip = trip;
    }

    public Set<Attraction> getAttractions() {
        return attractions;
    }

    public void setAttractions(Set<Attraction> attractions) {
        this.attractions = attractions;
    }
}
