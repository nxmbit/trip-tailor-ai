package com.ai.triptailor.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;
import java.util.List;

public class GenerateTravelPlanRequestDto {
    @NotBlank(message = "Destination is required")
    private String destination;

    @NotNull(message = "Travel start date is required")
    private Instant startDate;

    @NotNull(message = "Travel end date is required")
    private Instant endDate;

    private List<String> desiredDestinations;

    private List<String> desiredActivityTypes;

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public Instant getStartDate() {
        return startDate;
    }

    public void setStartDate(Instant startDate) {
        this.startDate = startDate;
    }

    public Instant getEndDate() {
        return endDate;
    }

    public void setEndDate(Instant endDate) {
        this.endDate = endDate;
    }

    public List<String> getDesiredDestinations() {
        return desiredDestinations;
    }

    public void setDesiredDestinations(List<String> desiredDestinations) {
        this.desiredDestinations = desiredDestinations;
    }

    public List<String> getDesiredActivityTypes() {
        return desiredActivityTypes;
    }

    public void setDesiredActivityTypes(List<String> desiredActivityTypes) {
        this.desiredActivityTypes = desiredActivityTypes;
    }
}