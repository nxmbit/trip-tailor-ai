package com.ai.triptailor.response;

import java.time.LocalDateTime;
import java.util.List;

public class TravelPlanDayDto {
    private int dayNumber;
    private String description;
    private LocalDateTime date;
    private List<AttractionDto> attractions;

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

    public List<AttractionDto> getAttractions() {
        return attractions;
    }

    public void setAttractions(List<AttractionDto> attractions) {
        this.attractions = attractions;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}