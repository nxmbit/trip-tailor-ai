package com.ai.triptailor.response;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.UUID;

public class TravelPlanInfoResponse {
    private UUID id;
    private String language;
    private String destination;
    private String imageUrl;
    private int tripLength;
    private Instant createdAt;
    private LocalDateTime travelStartDate;
    private LocalDateTime travelEndDate;

    public TravelPlanInfoResponse(UUID id, String language, String destination, String imageUrl, int tripLength,
                                  Instant createdAt, LocalDateTime travelStartDate, LocalDateTime travelEndDate) {
        this.id = id;
        this.language = language;
        this.destination = destination;
        this.imageUrl = imageUrl;
        this.tripLength = tripLength;
        this.createdAt = createdAt;
        this.travelStartDate = travelStartDate;
        this.travelEndDate = travelEndDate;
    }

    private TravelPlanInfoResponse(Builder builder) {
        this.id = builder.id;
        this.language = builder.language;
        this.destination = builder.destination;
        this.imageUrl = builder.imageUrl;
        this.tripLength = builder.numberOfDays;
        this.createdAt = builder.createdAt;
        this.travelStartDate = builder.travelStartDate;
        this.travelEndDate = builder.travelEndDate;
    }

    public TravelPlanInfoResponse() {
    }

    public static Builder builder() {
        return new Builder();
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
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

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public int getTripLength() {
        return tripLength;
    }

    public void setTripLength(int tripLength) {
        this.tripLength = tripLength;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
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

    public static class Builder {
        private UUID id;
        private String language;
        private String destination;
        private String imageUrl;
        private int numberOfDays;
        private Instant createdAt;
        private LocalDateTime travelStartDate;
        private LocalDateTime travelEndDate;

        public Builder id(UUID id) {
            this.id = id;
            return this;
        }

        public Builder language(String language) {
            this.language = language;
            return this;
        }

        public Builder destination(String destination) {
            this.destination = destination;
            return this;
        }

        public Builder imageUrl(String imageUrl) {
            this.imageUrl = imageUrl;
            return this;
        }

        public Builder numberOfDays(int numberOfDays) {
            this.numberOfDays = numberOfDays;
            return this;
        }

        public Builder createdAt(Instant createdAt) {
            this.createdAt = createdAt;
            return this;
        }

        public Builder travelStartDate(LocalDateTime travelStartDate) {
            this.travelStartDate = travelStartDate;
            return this;
        }

        public Builder travelEndDate(LocalDateTime travelEndDate) {
            this.travelEndDate = travelEndDate;
            return this;
        }

        public TravelPlanInfoResponse build() {
            return new TravelPlanInfoResponse(this);
        }
    }
}