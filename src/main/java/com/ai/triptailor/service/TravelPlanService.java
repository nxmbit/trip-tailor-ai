package com.ai.triptailor.service;

import com.ai.triptailor.model.TravelPlan;
import com.ai.triptailor.model.TravelPlanDay;
import com.ai.triptailor.model.UserPrincipal;
import com.ai.triptailor.repository.TravelPlanRepository;
import com.ai.triptailor.response.TravelPlanResponseDto;
import com.ai.triptailor.response.TravelPlanDayDto;
import com.ai.triptailor.response.AttractionDto;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class TravelPlanService {
    private final TravelPlanRepository travelPlanRepository;
    private final S3StorageService s3StorageService;

    @Autowired
    public TravelPlanService(
            TravelPlanRepository travelPlanRepository,
            S3StorageService s3StorageService) {
        this.travelPlanRepository = travelPlanRepository;
        this.s3StorageService = s3StorageService;
    }

    public TravelPlanResponseDto getTravelPlanById(UUID id, String language) {
        TravelPlan travelPlan = travelPlanRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Travel plan not found"));

        return convertToResponseDto(travelPlan, language);
    }

    public boolean isOwnedByCurrentUser(UUID travelPlanId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        // Get current user ID from UserPrincipal
        if (authentication.getPrincipal() instanceof UserPrincipal) {
            UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
            Long currentUserId = userPrincipal.getId();

            // Find the travel plan and check if it belongs to the current user
            return travelPlanRepository.findById(travelPlanId)
                    .map(travelPlan -> travelPlan.getUser().getId().equals(currentUserId))
                    .orElse(false);
        }

        return false;
    }

    public TravelPlanResponseDto getUserOwnedTravelPlanById(UUID id, String language) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        // Get current user ID from UserPrincipal
        if (!(authentication.getPrincipal() instanceof UserPrincipal)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not authorized");
        }

        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        Long currentUserId = userPrincipal.getId();

        // Find the travel plan
        TravelPlan travelPlan = travelPlanRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Travel plan not found"));

        // Check if the travel plan belongs to the current user
        if (!travelPlan.getUser().getId().equals(currentUserId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not authorized to access this travel plan");
        }

        return convertToResponseDto(travelPlan, language);
    }

    public TravelPlanResponseDto convertToResponseDto(TravelPlan travelPlan) {
        return convertToResponseDto(travelPlan, "en");
    }

    public TravelPlanResponseDto convertToResponseDto(TravelPlan travelPlan, String language) {
        TravelPlanResponseDto dto = new TravelPlanResponseDto();

        // Set basic trip information
        dto.setTravelPlanId(travelPlan.getId());
        dto.setDestination(getLocalizedText(travelPlan.getDestination(), language));
        dto.setDescription(getLocalizedText(travelPlan.getDescription(), language));
        dto.setBestTimeToVisit(getLocalizedText(travelPlan.getBestTimeToVisit(), language));
        dto.setDestinationHistory(getLocalizedText(travelPlan.getDestinationHistory(), language));
        dto.setTravelStartDate(travelPlan.getTravelStartDate());
        dto.setTravelEndDate(travelPlan.getTravelEndDate());
        dto.setGooglePlacesId(travelPlan.getGooglePlacesId());
        dto.setCreatedAt(travelPlan.getCreatedAt());
        dto.setLanguage(language);

        // Set image URL if available
        if (!StringUtils.isBlank(travelPlan.getImageFileName())) {
            String imageUrl = s3StorageService.generatePresignedUrl(travelPlan.getImageFileName())
                    .orElse(null);
            dto.setImageUrl(imageUrl);
        }

        // Set cuisine recommendations
        String[] cuisineRecommendations = travelPlan.getLocalCuisineRecommendations(language);
        if (ArrayUtils.isNotEmpty(cuisineRecommendations)) {
            dto.setLocalCuisineRecommendations(cuisineRecommendations);
        }

        // Map days and attractions
        if (travelPlan.getTravelPlanDays() != null) {
            List<TravelPlanDayDto> dayDtos = travelPlan.getTravelPlanDays().stream()
                    .sorted(Comparator.comparing(TravelPlanDay::getDayNumber))
                    .map(day -> {
                        TravelPlanDayDto dayDto = new TravelPlanDayDto();
                        dayDto.setDayNumber(day.getDayNumber());
                        dayDto.setDate(day.getDate());
                        dayDto.setDescription(getLocalizedText(day.getDescription(), language));

                        // Map attractions for this day
                        if (day.getAttractions() != null) {
                            List<AttractionDto> attractionDtos = day.getAttractions().stream()
                                    .map(attraction -> {
                                        AttractionDto attractionDto = new AttractionDto();
                                        attractionDto.setVisitOrder(attraction.getVisitOrder());
                                        attractionDto.setName(getLocalizedText(attraction.getName(), language));
                                        attractionDto.setDescription(getLocalizedText(attraction.getDescription(), language));
                                        attractionDto.setLatitude(attraction.getLatitude());
                                        attractionDto.setLongitude(attraction.getLongitude());
                                        attractionDto.setVisitDuration(attraction.getVisitDuration());
                                        attractionDto.setGooglePlacesId(attraction.getGooglePlacesId());
                                        attractionDto.setAverageRating(attraction.getAverageRating());
                                        attractionDto.setNumberOfUserRatings(attraction.getNumberOfUserRatings());

                                        // Generate image URL for attraction if available
                                        if (!StringUtils.isBlank(attraction.getImageFileName())) {
                                            String attractionImageUrl = s3StorageService.generatePresignedUrl(attraction.getImageFileName())
                                                    .orElse(null);
                                            attractionDto.setImageUrl(attractionImageUrl);
                                        }

                                        return attractionDto;
                                    })
                                    .collect(Collectors.toList());

                            dayDto.setAttractions(attractionDtos);
                        }

                        return dayDto;
                    })
                    .collect(Collectors.toList());

            dto.setItinerary(dayDtos);
        }

        return dto;
    }

    /**
     * Extracts localized text from a Map based on language code with fallback to English
     */
    private String getLocalizedText(Map<String, String> textMap, String language) {
        if (textMap == null) return "";
        return textMap.getOrDefault(language, textMap.getOrDefault("en", ""));
    }
}