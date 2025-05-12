package com.ai.triptailor.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.hypersistence.utils.hibernate.type.json.JsonType;
import jakarta.persistence.*;
import org.hibernate.annotations.Type;

import java.util.HashMap;
import java.util.Map;

@Entity
public class Attraction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "travel_plan_day_id", nullable = false)
    private TravelPlanDay travelPlanDay;

    @Type(JsonType.class)
    @Column(columnDefinition = "jsonb")
    private Map<String, String> name = new HashMap<>();

    @Type(JsonType.class)
    @Column(columnDefinition = "jsonb")
    private Map<String, String> description = new HashMap<>();

    private String googlePlacesId;
    private double latitude;
    private double longitude;
    private String imageFileName;
    private int visitOrder; // Order of visit in the trip day, evaluate if this is needed
    private int visitDuration; // in minutes
    private int numberOfUserRatings;
    private double averageRating;

    public Attraction() {}

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public TravelPlanDay setTravelPlanDay() {
        return travelPlanDay;
    }

    public void setTravelPlanDay(TravelPlanDay travelPlanDay) {
        this.travelPlanDay = travelPlanDay;
    }

    public Map<String, String> getName() {
        return name;
    }

    public void setName(Map<String, String> name) {
        this.name = name;
    }

    public void addName(String languageCode, String text) {
        this.name.put(languageCode, text);
    }

    public String getName(String languageCode) {
        return this.name.getOrDefault(languageCode, this.name.getOrDefault("en", ""));
    }

    public Map<String, String> getDescription() {
        return description;
    }

    public void setDescription(Map<String, String> description) {
        this.description = description;
    }

    public void addDescription(String languageCode, String text) {
        this.description.put(languageCode, text);
    }

    public String getDescription(String languageCode) {
        return this.description.getOrDefault(languageCode, this.description.getOrDefault("en", ""));
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public String getImageFileName() {
        return imageFileName;
    }

    public void setImageFileName(String imageUrl) {
        this.imageFileName = imageUrl;
    }

    public int getVisitOrder() {
        return visitOrder;
    }

    public void setVisitOrder(int visitOrder) {
        this.visitOrder = visitOrder;
    }

    public int getVisitDuration() {
        return visitDuration;
    }

    public void setVisitDuration(int visitDuration) {
        this.visitDuration = visitDuration;
    }

    public String getGooglePlacesId() {
        return googlePlacesId;
    }

    public void setGooglePlacesId(String googlePlacesId) {
        this.googlePlacesId = googlePlacesId;
    }

    public int getNumberOfUserRatings() {
        return numberOfUserRatings;
    }

    public void setNumberOfUserRatings(int numberOfUserRatings) {
        this.numberOfUserRatings = numberOfUserRatings;
    }

    public double getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(double rating) {
        this.averageRating = rating;
    }
}
