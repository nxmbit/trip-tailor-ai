package com.ai.triptailor.model;

import io.hypersistence.utils.hibernate.type.json.JsonType;
import jakarta.persistence.*;
import org.hibernate.annotations.Type;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Entity
public class Trip {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    private String imageFileName;

    @Type(JsonType.class)
    @Column(columnDefinition = "jsonb")
    private Map<String, String> destination = new HashMap<>();

    @Type(JsonType.class)
    @Column(columnDefinition = "jsonb")
    private Map<String, String> description = new HashMap<>();

    private String googlePlacesId;

    private Instant tripStartDate;

    private Instant tripEndDate;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @OneToMany(mappedBy = "trip", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<TripDay> tripDays;

    public Trip() {
    }

    public Trip(UUID id, String imageFileName, Map<String, String> destination,
                Map<String, String> description, Instant tripStartDate,
                Instant tripEndDate, User user) {
        this.id = id;
        this.imageFileName = imageFileName;
        this.destination = destination;
        this.description = description;
        this.tripStartDate = tripStartDate;
        this.tripEndDate = tripEndDate;
        this.user = user;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getImageFileName() {
        return imageFileName;
    }

    public void setImageFileName(String imageUrl) {
        this.imageFileName = imageUrl;
    }

    public Instant getTripStartDate() {
        return tripStartDate;
    }

    public void setTripStartDate(Instant tripStartDate) {
        this.tripStartDate = tripStartDate;
    }

    public Instant getTripEndDate() {
        return tripEndDate;
    }

    public void setTripEndDate(Instant tripEndDate) {
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

    public Map<String, String> getDestination() {
        return destination;
    }

    public void setDestination(Map<String, String> destination) {
        this.destination = destination;
    }

    public String getGooglePlacesId() {
        return googlePlacesId;
    }

    public void setGooglePlacesId(String googlePlacesId) {
        this.googlePlacesId = googlePlacesId;
    }

    public Map<String, String> getDescription() {
        return description;
    }

    public void setDescription(Map<String, String> description) {
        this.description = description;
    }

    public void addDestination(String languageCode, String text) {
        this.destination.put(languageCode, text);
    }

    public void addDescription(String languageCode, String text) {
        this.description.put(languageCode, text);
    }

    public String getDestination(String languageCode) {
        return this.destination.getOrDefault(languageCode, this.destination.getOrDefault("en", ""));
    }

    public String getDescription(String languageCode) {
        return this.description.getOrDefault(languageCode, this.description.getOrDefault("en", ""));
    }
}
