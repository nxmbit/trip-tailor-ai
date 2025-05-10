package com.ai.triptailor.response;

import java.time.LocalDateTime;
import java.util.List;

public class TravelPlanDay {
    private int dayNumber;
    private String description;
    private LocalDateTime date;
    private List<AttractionResponse> attractions;

    public int getDayNumber() {
        return dayNumber;
    }

    public void setDayNumber(int dayNumber) {
        this.dayNumber = dayNumber;
    }

    public LocalDateTime getDate() {
        return date;
    }

    public void setDate(LocalDateTime date) {
        this.date = date;
    }

    public List<AttractionResponse> getAttractions() {
        return attractions;
    }

    public void setAttractions(List<AttractionResponse> attractions) {
        this.attractions = attractions;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}