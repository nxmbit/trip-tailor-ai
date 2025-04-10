package com.ai.triptailor.controller;

import com.ai.triptailor.service.LlmTravelPlannerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TravelPlanController {
    private final LlmTravelPlannerService llmTravelPlannerService;

    @Autowired
    public TravelPlanController(LlmTravelPlannerService llmTravelPlannerService) {
        this.llmTravelPlannerService = llmTravelPlannerService;
    }
}
