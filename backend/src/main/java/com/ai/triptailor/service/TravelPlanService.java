package com.ai.triptailor.service;

import com.ai.triptailor.llm.enums.Language;
import com.ai.triptailor.model.TravelPlan;
import com.ai.triptailor.model.User;
import com.ai.triptailor.model.UserPrincipal;
import com.ai.triptailor.repository.TravelPlanRepository;
import com.ai.triptailor.response.*;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.time.LocalDateTime;
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

    public TravelPlanResponse getTravelPlanById(UUID id, String language) {
        TravelPlan travelPlan = travelPlanRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Travel plan not found"));

        return convertToResponseDto(travelPlan, language);
    }

    public boolean isOwnedByCurrentUser(UUID travelPlanId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        // Get current user ID from UserPrincipal
        if (authentication.getPrincipal() instanceof UserPrincipal userPrincipal) {
            Long currentUserId = userPrincipal.getId();

            // Find the travel plan and check if it belongs to the current user
            return travelPlanRepository.findById(travelPlanId)
                    .map(travelPlan -> travelPlan.getUser().getId().equals(currentUserId))
                    .orElse(false);
        }

        return false;
    }

    public TravelPlanResponse getUserOwnedTravelPlanById(UUID id, String language) {
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

    public void deleteTravelPlanById(UUID id) {
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
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not authorized to delete this travel plan");
        }

        // Delete the travel plan
        travelPlanRepository.delete(travelPlan);
    }

    public TravelPlanInfoPagingResponse getInfoOfTravelPlans(
            int page,
            int size,
            String sortBy,
            String sortDirection,
            String languageCode
    ) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        // Get current user ID from UserPrincipal
        if (!(authentication.getPrincipal() instanceof UserPrincipal)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not authorized");
        }

        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        Long currentUserId = userPrincipal.getId();

        // Validate language code
        Language language = Arrays.stream(Language.values())
                .filter(lang -> lang.getCode().equals(languageCode))
                .findFirst()
                .orElse(Language.ENGLISH);

        // Create sort direction
        Sort.Direction direction = "asc".equalsIgnoreCase(sortDirection) ?
                Sort.Direction.ASC : Sort.Direction.DESC;

        Pageable pageable = PageRequest.of(
                page,
                size,
                Sort.by(direction, sortBy)
        );

        Page<TravelPlan> travelPlansPage = travelPlanRepository.findByUserId(currentUserId, pageable);

        // Convert to response DTOs
        List<TravelPlanInfoResponse> travelPlanInfos = travelPlansPage.getContent().stream()
                .map(plan -> {
                    // Get image URL from s3
                    String imageUrl = null;
                    if (!StringUtils.isBlank(plan.getImageFileName())) {
                        imageUrl = s3StorageService.generatePresignedUrl(plan.getImageFileName()).orElse(null);
                    }

                    return TravelPlanInfoResponse.builder()
                            .id(plan.getId())
                            .language(language.getCode())
                            .destination(getLocalizedText(plan.getDestination(), language.getCode()))
                            .imageUrl(imageUrl)
                            .numberOfDays(plan.getTripLength())
                            .createdAt(plan.getCreatedAt())
                            .travelStartDate(plan.getTravelStartDate())
                            .travelEndDate(plan.getTravelEndDate())
                            .build();
                })
                .collect(Collectors.toList());

        return new TravelPlanInfoPagingResponse(
                travelPlanInfos,
                size,
                page,
                travelPlansPage.getTotalPages(),
                (int) travelPlansPage.getTotalElements(),
                travelPlanInfos.isEmpty()
        );
    }

    public TravelPlanResponse convertToResponseDto(TravelPlan travelPlan) {
        return convertToResponseDto(travelPlan, Language.ENGLISH.getCode());
    }

    public TravelPlanResponse convertToResponseDto(TravelPlan travelPlan, String language) {
        TravelPlanResponse dto = new TravelPlanResponse();

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
            List<TravelPlanDay> dayDtos = travelPlan.getTravelPlanDays().stream()
                    .sorted(Comparator.comparing(com.ai.triptailor.model.TravelPlanDay::getDayNumber))
                    .map(day -> {
                        TravelPlanDay dayDto = new TravelPlanDay();
                        dayDto.setDayNumber(day.getDayNumber());
                        dayDto.setDate(day.getDate());
                        dayDto.setDescription(getLocalizedText(day.getDescription(), language));

                        // Map attractions for this day
                        if (day.getAttractions() != null) {
                            List<AttractionResponse> attractionResponses = day.getAttractions().stream()
                                    .sorted(Comparator.comparing(com.ai.triptailor.model.Attraction::getVisitOrder))
                                    .map(attraction -> {
                                        AttractionResponse attractionResponse = new AttractionResponse();
                                        attractionResponse.setVisitOrder(attraction.getVisitOrder());
                                        attractionResponse.setName(getLocalizedText(attraction.getName(), language));
                                        attractionResponse.setDescription(getLocalizedText(attraction.getDescription(), language));
                                        attractionResponse.setLatitude(attraction.getLatitude());
                                        attractionResponse.setLongitude(attraction.getLongitude());
                                        attractionResponse.setVisitDuration(attraction.getVisitDuration());
                                        attractionResponse.setGooglePlacesId(attraction.getGooglePlacesId());
                                        attractionResponse.setAverageRating(attraction.getAverageRating());
                                        attractionResponse.setNumberOfUserRatings(attraction.getNumberOfUserRatings());

                                        // Generate image URL for attraction if available
                                        if (!StringUtils.isBlank(attraction.getImageFileName())) {
                                            String attractionImageUrl = s3StorageService.generatePresignedUrl(attraction.getImageFileName())
                                                    .orElse(null);
                                            attractionResponse.setImageUrl(attractionImageUrl);
                                        }

                                        return attractionResponse;
                                    })
                                    .collect(Collectors.toList());

                            dayDto.setAttractions(attractionResponses);
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