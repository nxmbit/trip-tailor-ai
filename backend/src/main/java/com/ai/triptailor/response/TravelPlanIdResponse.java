package com.ai.triptailor.response;

import java.util.UUID;

public class TravelPlanIdResponse {
    private UUID id;

    public TravelPlanIdResponse(UUID id) {
        this.id = id;
    }

    public UUID getId() {
        return id;
    }
}