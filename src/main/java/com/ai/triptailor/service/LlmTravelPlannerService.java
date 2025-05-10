package com.ai.triptailor.service;

import com.ai.triptailor.llm.enums.Language;
import com.ai.triptailor.llm.schema.AttractionSchema;
import com.ai.triptailor.llm.schema.TravelPlanDaySchema;
import com.ai.triptailor.llm.schema.TravelPlanSchema;
import com.ai.triptailor.model.Attraction;
import com.ai.triptailor.model.TravelPlan;
import com.ai.triptailor.model.TravelPlanDay;
import com.ai.triptailor.model.User;
import com.ai.triptailor.repository.TravelPlanRepository;
import com.ai.triptailor.request.GenerateTravelPlanRequest;
import com.ai.triptailor.llm.schema.DestinationDescriptionSchema;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionException;
import java.util.concurrent.ExecutionException;

@Service
public class LlmTravelPlannerService {
    private static final Logger logger = LoggerFactory.getLogger(LlmTravelPlannerService.class);

    private final S3StorageService s3StorageService;
    private final GoogleTimeSpentService googleTimeSpentService;
    private final GoogleMapsService googleMapsService;
    private final ChatClient chatClient;
    private final UserProfileService userProfileService;
    private final TravelPlanRepository travelPlanRepository;

    private final String SYSTEM_PROMPT = "You are a travel planner.";

    @Autowired
    public LlmTravelPlannerService(
            S3StorageService s3StorageService,
            GoogleTimeSpentService googleTimeSpentService,
            GoogleMapsService googleMapsService,
            ChatClient.Builder chatClientBuilder,
            UserProfileService userProfileService,
            TravelPlanRepository travelPlanRepository
    ) {
        this.s3StorageService = s3StorageService;
        this.googleTimeSpentService = googleTimeSpentService;
        this.googleMapsService = googleMapsService;
        this.chatClient = chatClientBuilder.build();
        this.userProfileService = userProfileService;
        this.travelPlanRepository = travelPlanRepository;
    }

    @Transactional
    public UUID generateTravelPlan(@Valid GenerateTravelPlanRequest request) {
        TravelPlan travelPlan = new TravelPlan();
        travelPlan.addDestination("en", request.getDestination());
        travelPlan.setTravelStartDate(request.getStartDate());
        travelPlan.setTravelEndDate(request.getEndDate());
        validateTravelDates(travelPlan);

        try {
            // Get trip duration
            int tripDuration = calculateTravelDuration(travelPlan.getTravelStartDate(), travelPlan.getTravelEndDate());

            // Search for place using Google Maps API, if not found throw an exception
            var placesSearchResult = googleMapsService.searchPlace(request.getDestination());
            if (placesSearchResult.isEmpty()) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                        "Could not find the destination: " + request.getDestination());
            }
            var place = placesSearchResult.get();
            travelPlan.setGooglePlacesId(place.placeId);

            // For more variety across different travel plans to the same place,
            // get random photo from top 5 photo search results
            CompletableFuture.runAsync(() -> {
                try {
                    googleMapsService.getRandomImageFromTopNPhotos(place, 5)
                            .ifPresent(imageBytes -> {
                                s3StorageService.uploadFile(imageBytes, "image/jpeg", "jpg")
                                        .ifPresent(travelPlan::setImageFileName);
                            });
                } catch (Exception e) {
                    logger.warn("Failed to retrieve or upload destination image", e);
                    // continue without image
                }
            });

            // Generate trip description
            CompletableFuture<DestinationDescriptionSchema> descFuture = CompletableFuture.supplyAsync(() ->
                    generateDestinationDescription(request.getDestination()));

            // Generate itinerary
            CompletableFuture<TravelPlanSchema> planFuture = CompletableFuture.supplyAsync(() ->
                    generateTravelPlan(tripDuration, request.getDestination(),
                            request.getDesiredAttractions(),
                            travelPlan.getTravelStartDate(), travelPlan.getTravelEndDate()));

            CompletableFuture.allOf(descFuture, planFuture).join();
            DestinationDescriptionSchema description = descFuture.get();
            TravelPlanSchema travelPlanSchema = planFuture.get();
            setDestinationDescriptionSchemaInTravelPlan(travelPlan, description, Language.ENGLISH);

            List<CompletableFuture<TravelPlanDay>> dayFutures = travelPlanSchema.days().stream()
                    .map(daySchema -> CompletableFuture.supplyAsync(() -> {
                        TravelPlanDay day = new TravelPlanDay();
                        day.setDayNumber(daySchema.dayNumber());
                        day.setDate(daySchema.date());
                        day.addDescription("en", daySchema.description());
                        day.setTravelPlan(travelPlan);

                        List<CompletableFuture<Attraction>> attractionFutures = daySchema.attractions().stream()
                                .map(attractionSchema -> CompletableFuture.supplyAsync(() -> {
                                    Attraction attraction = new Attraction();
                                    attraction.addName("en", attractionSchema.name());
                                    attraction.addDescription("en", attractionSchema.description());
                                    attraction.setVisitOrder(attractionSchema.visitingOrder());

                                    // add google maps data
                                    googleMapsService.searchPlace(attractionSchema.name() + " " + request.getDestination())
                                            .ifPresent(placeResult -> {
                                                // Set coordinates
                                                googleMapsService.getLatitude(placeResult)
                                                        .ifPresent(attraction::setLatitude);
                                                googleMapsService.getLongitude(placeResult)
                                                        .ifPresent(attraction::setLongitude);

                                                // Set rating and user rating count
                                                attraction.setAverageRating(placeResult.rating);
                                                attraction.setNumberOfUserRatings(placeResult.userRatingsTotal);
                                                attraction.setGooglePlacesId(placeResult.placeId);

                                                googleMapsService.getOpeningHours(placeResult)
                                                        .ifPresent(hours -> {
                                                            logger.debug("Opening hours: {}", Arrays.toString(hours));
                                                        });

                                                // Get and store a photo
                                                googleMapsService.getRandomImageFromTopNPhotos(placeResult, 3)
                                                        .ifPresent(imageBytes -> {
                                                            s3StorageService.uploadFile(imageBytes, "image/jpeg", "jpg")
                                                                    .ifPresent(attraction::setImageFileName);
                                                        });

                                                // Get average time spent
                                                googleTimeSpentService.getTimeSpent(
                                                        googleMapsService.getName(placeResult),
                                                        googleMapsService.getAddress(placeResult)
                                                ).ifPresent(attraction::setVisitDuration);
                                            });

                                    return attraction;
                                }))
                                .toList();

                        // wait for all attractions to complete and add them to the day
                        List<Attraction> attractions = attractionFutures.stream()
                                .map(future -> {
                                    try {
                                        return future.join();
                                    } catch (CompletionException e) {
                                        logger.warn("Error processing attraction: {}", e.getCause().getMessage());
                                        return null;
                                    }
                                })
                                .filter(Objects::nonNull)
                                .toList();

                        // Add attractions to day
                        attractions.forEach(attraction -> {
                            day.addAttraction(attraction);
                            attraction.setTravelPlanDay(day);
                        });

                        return day;
                    }))
                    .toList();

            // Wait for all days to complete and add them to the travel plan
            dayFutures.forEach(future -> {
                TravelPlanDay day = future.join();
                travelPlan.addTravelPlanDay(day);
            });

            translateInParallel(description, travelPlanSchema, travelPlan);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "Process was interrupted while generating travel plan", e);
        } catch (ExecutionException e) {
            Throwable cause = e.getCause();
            if (cause instanceof ResponseStatusException) {
                throw (ResponseStatusException) cause;
            }
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "Error generating travel plan", e);
        }

        // Associate trip with the current user - fail if user cannot be found
        User currentUser = userProfileService.getCurrentUser();

        if (currentUser.getGenerationsNumber() == null) {
            currentUser.setGenerationsNumber(1L);
        } else {
            currentUser.setGenerationsNumber(currentUser.getGenerationsNumber() + 1);
        }

        travelPlan.setUser(currentUser);
        travelPlan.setCreatedAt(Instant.now());
        TravelPlan savedTravelPlan = travelPlanRepository.save(travelPlan);

        return savedTravelPlan.getId();
    }

    private DestinationDescriptionSchema generateDestinationDescription(String destination) {
        try {
            return chatClient.prompt()
                    .system(SYSTEM_PROMPT)
                    .user("Generate a description about the travel destination " + destination)
                    .call()
                    .entity(DestinationDescriptionSchema.class);
        } catch (Exception e) {
            if (e instanceof org.springframework.ai.retry.NonTransientAiException) {
                throw e;
            }

            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Failed to generate travel plan", e);
        }
    }

    private TravelPlanSchema generateTravelPlan(int tripDuration, String destination, List<String> desiredAttractions,
                                                LocalDateTime startDate, LocalDateTime endDate) {
        try {
            StringBuilder promptBuilder = new StringBuilder();
            promptBuilder.append("Generate a detailed daily itinerary for a ")
                    .append(tripDuration)
                    .append(" day trip to ")
                    .append(destination)
                    .append(" from ")
                    .append(startDate)
                    .append(" to ")
                    .append(endDate);

            if (desiredAttractions != null && !desiredAttractions.isEmpty()) {
                promptBuilder.append(". Make sure to also include the following attractions that the user specifically wants to see: ");
                promptBuilder.append(String.join(", ", desiredAttractions));
                promptBuilder.append("Also suggest other must-see attractions, local experiences, and hidden gems beyond what the user requested.");
            }

            return chatClient.prompt()
                    .system(SYSTEM_PROMPT)
                    .user(promptBuilder.toString())
                    .call()
                    .entity(TravelPlanSchema.class);
        } catch (Exception e) {
            if (e instanceof org.springframework.ai.retry.NonTransientAiException) {
                throw e;
            }

            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Failed to generate travel plan", e);
        }
    }

    private void translateInParallel(DestinationDescriptionSchema description,
                                     TravelPlanSchema travelPlanSchema,
                                     TravelPlan travelPlan) {
        List<CompletableFuture<Void>> translationFutures = new ArrayList<>();

        Optional<String> descriptionJson = convertToJson(description);
        Optional<String> planJson = convertToJson(travelPlanSchema);

        // create translation futures
        for (Language language : Language.values()) {
            if (language == Language.ENGLISH) continue;
            String languageName = language.getName();

            if (planJson.isPresent()) {
                CompletableFuture<Void> planFuture = CompletableFuture.runAsync(() -> {
                    try {
                        String safeJson = planJson.get()
                                .replace("{", "rightCurlyBrace")
                                .replace("}", "leftCurlyBrace")
                                .replace("[", "leftSquareBracket")
                                .replace("]", "rightSquareBracket");

                        TravelPlanSchema translatedPlan = chatClient.prompt()
                                .system("You are responsible for translating travel itineraries.")
                                .user("Translate this travel itinerary from English to " + languageName +
                                        ". Keep the exact same structure and maintain all dates and numbers:\n" + safeJson)
                                .call()
                                .entity(TravelPlanSchema.class);

                        synchronized (travelPlan) {
                            setTravelPlanSchemaInTravelPlan(travelPlan, translatedPlan, language);
                        }
                    } catch (Exception e) {
                        logger.error("Failed to translate plan to {}: {}", languageName, e.getMessage());
                        synchronized (travelPlan) {
                            setTravelPlanSchemaInTravelPlan(travelPlan, travelPlanSchema, language);
                        }
                    }
                });
                translationFutures.add(planFuture);
            } else {
                logger.error("Failed to convert TravelPlanSchema to JSON, falling back to English");
                setTravelPlanSchemaInTravelPlan(travelPlan, travelPlanSchema, language);
            }

            if (descriptionJson.isPresent()) {
                CompletableFuture<Void> descriptionFuture = CompletableFuture.runAsync(() -> {
                    try {
                        String safeJson = descriptionJson.get()
                                .replace("{", "rightCurlyBrace")
                                .replace("}", "leftCurlyBrace")
                                .replace("[", "leftSquareBracket")
                                .replace("]", "rightSquareBracket");

                        DestinationDescriptionSchema translatedDesc = chatClient.prompt()
                                .system("You are responsible for translating the description of travel plans.")
                                .user("Translate this travel plan description from English to " +
                                        languageName + ":\n" + safeJson)
                                .call()
                                .entity(DestinationDescriptionSchema.class);

                        synchronized (travelPlan) {
                            setDestinationDescriptionSchemaInTravelPlan(travelPlan, translatedDesc, language);
                        }
                    } catch (Exception e) {
                        logger.error("Failed to translate description to {}: {}", languageName, e.getMessage());
                        // fall back to English
                        synchronized (travelPlan) {
                            setDestinationDescriptionSchemaInTravelPlan(travelPlan, description, language);
                        }
                    }
                });
                translationFutures.add(descriptionFuture);
            } else {
                logger.error("Failed to convert DestinationDescriptionSchema to JSON, falling back to English");
                setDestinationDescriptionSchemaInTravelPlan(travelPlan, description, language);
            }
        }

        CompletableFuture.allOf(translationFutures.toArray(new CompletableFuture[0])).join();
    }

    private Optional<String> convertToJson(Object object) {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());
        objectMapper.configure(com.fasterxml.jackson.databind.SerializationFeature.WRITE_DATES_AS_TIMESTAMPS, false);

        try {
            return Optional.of(objectMapper.writeValueAsString(object));
        } catch (JsonProcessingException e) {
            logger.error("Error converting object to JSON", e);
            return Optional.empty();
        }
    }

    private void setDestinationDescriptionSchemaInTravelPlan(
            TravelPlan travelPlan,
            DestinationDescriptionSchema destinationDescriptionSchema,
            Language language
    ) {
        String languageCode = language.getCode();

        travelPlan.addDestination(languageCode, destinationDescriptionSchema.destinationName());
        travelPlan.addDescription(languageCode, destinationDescriptionSchema.aboutTheDestination());
        travelPlan.addBestTimeToVisit(languageCode, destinationDescriptionSchema.bestTimeToVisit());
        travelPlan.addLocalCuisineRecommendations(languageCode, destinationDescriptionSchema.localCuisineRecommendations());
        travelPlan.addDestinationHistory(languageCode, destinationDescriptionSchema.destinationHistory());
    }

    private void setTravelPlanSchemaInTravelPlan(
            TravelPlan travelPlan,
            TravelPlanSchema travelPlanSchema,
            Language language
    ) {
        String languageCode = language.getCode();

        for (TravelPlanDaySchema daySchema : travelPlanSchema.days()) {
            // Find corresponding TravelPlanDay in travelPlan
            TravelPlanDay day = travelPlan.getTravelPlanDays().stream()
                    .filter(d -> d.getDayNumber() == daySchema.dayNumber())
                    .findFirst()
                    .orElse(null);

            if (day == null) {
                logger.warn("No matching day found for day number: {}", daySchema.dayNumber());
                continue;
            }

            day.addDescription(languageCode, daySchema.description());

            for (AttractionSchema attractionSchema : daySchema.attractions()) {
                // Find corresponding Attraction in day
                Attraction attraction = day.getAttractions().stream()
                        .filter(a -> a.getVisitOrder() == attractionSchema.visitingOrder())
                        .findFirst()
                        .orElse(null);

                if (attraction == null) {
                    logger.warn("No matching attraction found for visit order: {}", attractionSchema.visitingOrder());
                    continue;
                }

                attraction.addName(languageCode, attractionSchema.name());
                attraction.addDescription(languageCode, attractionSchema.description());
            }
        }

    }

    private void validateTravelDates(TravelPlan travelPlan) {
        int days = calculateTravelDuration(travelPlan.getTravelStartDate(), travelPlan.getTravelEndDate());

        if (days < 1) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Travel duration must be at least 1 day");
        }
        if (days > 10) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Travel duration cannot exceed 10 days");
        }
    }

    private int calculateTravelDuration(LocalDateTime startDate, LocalDateTime endDate) {
        return (int) Duration.between(startDate.toLocalDate().atStartOfDay(), endDate.toLocalDate().atStartOfDay())
                .toDays() + 1;
    }
}
