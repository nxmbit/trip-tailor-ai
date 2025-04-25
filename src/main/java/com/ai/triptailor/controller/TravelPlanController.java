package com.ai.triptailor.controller;

import com.ai.triptailor.request.GenerateTravelPlanRequestDto;
import com.ai.triptailor.model.Trip;
import com.ai.triptailor.service.LlmTravelPlannerService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/trip-plans")
public class TravelPlanController {
    private final LlmTravelPlannerService llmTravelPlannerService;

    @Autowired
    public TravelPlanController(LlmTravelPlannerService llmTravelPlannerService) {
        this.llmTravelPlannerService = llmTravelPlannerService;
    }

    @PostMapping("/generate")
    public ResponseEntity<Trip> generateTravelPlan(@Valid @RequestBody GenerateTravelPlanRequestDto request) {
        return ResponseEntity.ok(llmTravelPlannerService.generateTravelPlan(request));
    }

}
