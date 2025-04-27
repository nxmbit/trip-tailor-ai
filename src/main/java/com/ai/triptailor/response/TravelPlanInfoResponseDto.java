package com.ai.triptailor.response;

import java.time.Instant;
import java.util.UUID;

public class TravelPlanInfoResponseDto {
    private UUID id;
    private String name;
    private String imageUrl;
    private int numberOfDays;
    private Instant createdAt;

    //TODO do we want to add a field for the user id?
}
