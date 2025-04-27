package com.ai.triptailor.response;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public class TravelPlanResponseDto {
    private UUID travelPlanId;
    private String language;
    private String destination;
    private String description;
    private String bestTimeToVisit;
    private String destinationHistory;
    private String googlePlacesId;
    private LocalDateTime travelStartDate;
    private LocalDateTime travelEndDate;
    private String imageUrl;
    private Instant createdAt;
    private String[] localCuisineRecommendations;
    private List<TravelPlanDayDto> itinerary;

    public UUID getTravelPlanId() {
        return travelPlanId;
    }

    public void setTravelPlanId(UUID travelPlanId) {
        this.travelPlanId = travelPlanId;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getBestTimeToVisit() {
        return bestTimeToVisit;
    }

    public void setBestTimeToVisit(String bestTimeToVisit) {
        this.bestTimeToVisit = bestTimeToVisit;
    }

    public String getDestinationHistory() {
        return destinationHistory;
    }

    public void setDestinationHistory(String destinationHistory) {
        this.destinationHistory = destinationHistory;
    }

    public LocalDateTime getTravelStartDate() {
        return travelStartDate;
    }

    public void setTravelStartDate(LocalDateTime travelStartDate) {
        this.travelStartDate = travelStartDate;
    }

    public LocalDateTime getTravelEndDate() {
        return travelEndDate;
    }

    public void setTravelEndDate(LocalDateTime travelEndDate) {
        this.travelEndDate = travelEndDate;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String[] getLocalCuisineRecommendations() {
        return localCuisineRecommendations;
    }

    public void setLocalCuisineRecommendations(String[] localCuisineRecommendations) {
        this.localCuisineRecommendations = localCuisineRecommendations;
    }

    public List<TravelPlanDayDto> getItinerary() {
        return itinerary;
    }

    public void setItinerary(List<TravelPlanDayDto> itinerary) {
        this.itinerary = itinerary;
    }

    public String getGooglePlacesId() {
        return googlePlacesId;
    }

    public void setGooglePlacesId(String googlePlacesId) {
        this.googlePlacesId = googlePlacesId;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }
}