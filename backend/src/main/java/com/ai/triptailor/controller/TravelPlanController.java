package com.ai.triptailor.controller;

import com.ai.triptailor.request.GenerateTravelPlanRequest;
import com.ai.triptailor.request.NearbyPlacesSummaryRequest;
import com.ai.triptailor.response.NearbyPlacesSummaryResponse;
import com.ai.triptailor.response.TravelPlanIdResponse;
import com.ai.triptailor.response.TravelPlanInfoPagingResponse;
import com.ai.triptailor.response.TravelPlanResponse;
import com.ai.triptailor.service.LlmTravelPlannerService;
import com.ai.triptailor.service.NearbyPlacesSummaryService;
import com.ai.triptailor.service.TravelPlanService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/travel-plans")
public class TravelPlanController {
    private final LlmTravelPlannerService llmTravelPlannerService;
    private final NearbyPlacesSummaryService nearbyPlacesSummaryService;
    private final TravelPlanService travelPlanService;

    @Autowired
    public TravelPlanController(LlmTravelPlannerService llmTravelPlannerService, TravelPlanService travelPlanService,
                                NearbyPlacesSummaryService nearbyPlacesSummaryService) {
        this.llmTravelPlannerService = llmTravelPlannerService;
        this.travelPlanService = travelPlanService;
        this.nearbyPlacesSummaryService = nearbyPlacesSummaryService;
    }

    @PostMapping("/generate")
    public ResponseEntity<TravelPlanIdResponse> generateTravelPlan(@Valid @RequestBody GenerateTravelPlanRequest request) {
        UUID travelPlanId = llmTravelPlannerService.generateTravelPlan(request);
        return ResponseEntity.ok(new TravelPlanIdResponse(travelPlanId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TravelPlanResponse> getTravelPlan(
            @PathVariable UUID id,
            @RequestParam(defaultValue = "en") String language) {

        // Get the travel plan and check if it belongs to the current user
        TravelPlanResponse travelPlan = travelPlanService.getUserOwnedTravelPlanById(id, language);

        return ResponseEntity.ok(travelPlan);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTravelPlan(@PathVariable UUID id) {
        travelPlanService.deleteTravelPlanById(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/plans")
    public ResponseEntity<TravelPlanInfoPagingResponse> getInfoOfTravelPlans(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDirection,
            @RequestParam(defaultValue = "en") String language
    ) {

        List<String> validSortFields = Arrays.asList("createdAt", "travelStartDate", "travelEndDate",
                "destination", "tripLength");
        if (!validSortFields.contains(sortBy)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Invalid sort field. Valid options are: " + String.join(", ", validSortFields));
        }

        TravelPlanInfoPagingResponse response = travelPlanService.getInfoOfTravelPlans(
                page,
                pageSize,
                sortBy,
                sortDirection,
                language
        );

        return ResponseEntity.ok(response);
    }

    @PostMapping("/nearby-summary")
    public ResponseEntity<NearbyPlacesSummaryResponse> getNearbyPlacesSummary(
            @Valid @RequestBody NearbyPlacesSummaryRequest request) {

        if (request.getRadiusMeters() <= 0) {
            request.setRadiusMeters(1000); // Default 1km
        }
        if (request.getMaxAttractions() <= 0) {
            request.setMaxAttractions(10); // Default 10 attractions
        }
        if (request.getLanguage() == null || request.getLanguage().isEmpty()) {
            request.setLanguage("en");
        }

        NearbyPlacesSummaryResponse response = nearbyPlacesSummaryService.getNearbyPlacesSummary(request);
        return ResponseEntity.ok(response);
    }
}
