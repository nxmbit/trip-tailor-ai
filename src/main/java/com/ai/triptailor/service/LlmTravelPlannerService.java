package com.ai.triptailor.service;

import com.ai.triptailor.dto.GenerateTravelPlanRequestDto;
import com.ai.triptailor.model.Trip;
import jakarta.validation.Valid;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Locale;

@Service
public class LlmTravelPlannerService {
    private final S3StorageService s3StorageService;
    private final GoogleTimeSpentService googleTimeSpentService;
    private final OpenAiChatModel openAiChatModel;

    @Autowired
    public LlmTravelPlannerService(
            S3StorageService s3StorageService,
            GoogleTimeSpentService googleTimeSpentService, OpenAiChatModel openAiChatModel
    ) {
        this.s3StorageService = s3StorageService;
        this.googleTimeSpentService = googleTimeSpentService;
        this.openAiChatModel = openAiChatModel;
    }

    public Trip generateTravelPlan(@Valid GenerateTravelPlanRequestDto request) {
        Trip trip = new Trip();
        trip.addDestination("en", request.getDestination());
        trip.setTripStartDate(request.getStartDate());
        trip.setTripEndDate(request.getEndDate());

        return trip;
    }
}
