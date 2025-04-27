package com.ai.triptailor.controller;

import com.ai.triptailor.request.GenerateTravelPlanRequestDto;
import com.ai.triptailor.response.TravelPlanIdResponse;
import com.ai.triptailor.response.TravelPlanResponseDto;
import com.ai.triptailor.service.LlmTravelPlannerService;
import com.ai.triptailor.service.TravelPlanService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/travel-plans")
public class TravelPlanController {
    private final LlmTravelPlannerService llmTravelPlannerService;
    private final TravelPlanService travelPlanService;

    @Autowired
    public TravelPlanController(LlmTravelPlannerService llmTravelPlannerService, TravelPlanService travelPlanService) {
        this.llmTravelPlannerService = llmTravelPlannerService;
        this.travelPlanService = travelPlanService;
    }

    @PostMapping("/generate")
    public ResponseEntity<TravelPlanIdResponse> generateTravelPlan(@Valid @RequestBody GenerateTravelPlanRequestDto request) {
        UUID travelPlanId = llmTravelPlannerService.generateTravelPlan(request);
        return ResponseEntity.ok(new TravelPlanIdResponse(travelPlanId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TravelPlanResponseDto> getTravelPlan(
            @PathVariable UUID id,
            @RequestParam(defaultValue = "en") String language) {

        // Get the travel plan and check if it belongs to the current user
        TravelPlanResponseDto travelPlan = travelPlanService.getUserOwnedTravelPlanById(id, language);

        return ResponseEntity.ok(travelPlan);
    }
}
