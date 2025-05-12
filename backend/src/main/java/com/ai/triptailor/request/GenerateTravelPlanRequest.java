package com.ai.triptailor.request;

import jakarta.validation.constraints.NotBlank;

import java.time.LocalDateTime;
import java.util.List;

public class GenerateTravelPlanRequest {
    @NotBlank(message = "Destination is required")
    private String destination;

    private LocalDateTime startDate;

    private LocalDateTime endDate;

    private List<String> desiredAttractions;

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public LocalDateTime getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDateTime startDate) {
        this.startDate = startDate;
    }

    public LocalDateTime getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDateTime endDate) {
        this.endDate = endDate;
    }

    public List<String> getDesiredAttractions() {
        return desiredAttractions;
    }

    public void setDesiredAttractions(List<String> desiredAttractions) {
        this.desiredAttractions = desiredAttractions;
    }
}