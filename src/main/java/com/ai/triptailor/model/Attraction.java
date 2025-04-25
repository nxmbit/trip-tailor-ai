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
    @JoinColumn(name = "trip_day_id", nullable = false)
    private TripDay tripDay;

    @Type(JsonType.class)
    @Column(columnDefinition = "jsonb")
    private Map<String, String> name = new HashMap<>();

    @Type(JsonType.class)
    @Column(columnDefinition = "jsonb")
    private Map<String, String> description = new HashMap<>();

    private double latitude;
    private double longitude;
    private String imageFileName;
    private int visitOrder; // Order of visit in the trip day, evaluate if this is needed
    private double visitDuration; // in hours

    public Attraction() {}

    public Attraction(Long id, TripDay tripDay, Map<String, String> name, Map<String, String> description,
                      double latitude, double longitude, String imageFileName, int visitOrder, double visitDuration) {
        this.id = id;
        this.tripDay = tripDay;
        this.name = name;
        this.description = description;
        this.latitude = latitude;
        this.longitude = longitude;
        this.imageFileName = imageFileName;
        this.visitOrder = visitOrder;
        this.visitDuration = visitDuration;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public TripDay getTripDay() {
        return tripDay;
    }

    public void setTripDay(TripDay tripDay) {
        this.tripDay = tripDay;
    }

    public Map<String, String> getName() {
        return name;
    }

    public void setName(Map<String, String> name) {
        this.name = name;
    }

    public Map<String, String> getDescription() {
        return description;
    }

    public void setDescription(Map<String, String> description) {
        this.description = description;
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

    public double getVisitDuration() {
        return visitDuration;
    }

    public void setVisitDuration(double visitDuration) {
        this.visitDuration = visitDuration;
    }
}
