package com.ai.triptailor.response;

import java.util.List;

public class NearbyPlacesSummaryResponse {
    private String destination;
    private List<AttractionResponse> attractions;

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public List<AttractionResponse> getAttractions() {
        return attractions;
    }

    public void setAttractions(List<AttractionResponse> attractions) {
        this.attractions = attractions;
    }
}
