package com.ai.triptailor.request;

import jakarta.validation.constraints.NotNull;

public class NearbyPlacesSummaryRequest {
    @NotNull(message = "Latitude is required")
    private double latitude;

    @NotNull(message = "Longitude is required")
    private double longitude;

    int radiusMeters;
    int maxAttractions;
    String language;

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

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public int getRadiusMeters() {
        return radiusMeters;
    }

    public void setRadiusMeters(int radiusMeters) {
        this.radiusMeters = radiusMeters;
    }

    public int getMaxAttractions() {
        return maxAttractions;
    }

    public void setMaxAttractions(int maxAttractions) {
        this.maxAttractions = maxAttractions;
    }
}
