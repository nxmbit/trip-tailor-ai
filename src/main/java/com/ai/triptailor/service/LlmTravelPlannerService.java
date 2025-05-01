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
import com.ai.triptailor.repository.UserRepository;
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
import java.util.Arrays;
import java.util.Optional;
import java.util.UUID;

@Service
public class LlmTravelPlannerService {
    private static final Logger logger = LoggerFactory.getLogger(LlmTravelPlannerService.class);

    private final S3StorageService s3StorageService;
    private final GoogleTimeSpentService googleTimeSpentService;
    private final GoogleMapsService googleMapsService;
    private final ChatClient chatClient;
    private final UserProfileService userProfileService;
    private final TravelPlanRepository travelPlanRepository;
    private final UserRepository userRepository;

    private final String SYSTEM_PROMPT = "You are a travel planner.";

    @Autowired
    public LlmTravelPlannerService(
            S3StorageService s3StorageService,
            GoogleTimeSpentService googleTimeSpentService,
            GoogleMapsService googleMapsService,
            ChatClient.Builder chatClientBuilder,
            UserProfileService userProfileService,
            TravelPlanRepository travelPlanRepository,
            UserRepository userRepository
    ) {
        this.s3StorageService = s3StorageService;
        this.googleTimeSpentService = googleTimeSpentService;
        this.googleMapsService = googleMapsService;
        this.chatClient = chatClientBuilder.build();
        this.userProfileService = userProfileService;
        this.travelPlanRepository = travelPlanRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public UUID generateTravelPlan(@Valid GenerateTravelPlanRequest request) {
        TravelPlan travelPlan = new TravelPlan();
        travelPlan.addDestination("en", request.getDestination());
        travelPlan.setTravelStartDate(request.getStartDate());
        travelPlan.setTravelEndDate(request.getEndDate());
        validateTravelDates(travelPlan);

        // Get trip duration
        int tripDuration = calculateTravelDuration(travelPlan.getTravelStartDate(), travelPlan.getTravelEndDate());

        // Search for place using Google Maps API, if not found throw an exception
        var placesSearchResult = googleMapsService.searchPlace(request.getDestination());
        if (placesSearchResult.isEmpty()) {
            throw new RuntimeException("Destination not found");
        }
        var place = placesSearchResult.get();
        travelPlan.setGooglePlacesId(place.placeId);

        // For more variety across different travel plans to the same place,
        // get random photo from top 5 photo search results
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

        // Generate trip description
        DestinationDescriptionSchema description = generateDestinationDescription(request.getDestination());
        setDestinationDescriptionSchemaInTravelPlan(travelPlan, description, Language.ENGLISH);

        // Generate itinerary
        TravelPlanSchema travelPlanSchema = generateTravelPlan(tripDuration, request.getDestination(),
                travelPlan.getTravelStartDate(), travelPlan.getTravelEndDate());

        // Create travel plan days with attractions from the generated schema
        for (TravelPlanDaySchema daySchema : travelPlanSchema.days()) {
            TravelPlanDay day = new TravelPlanDay();
            day.setDayNumber(daySchema.dayNumber());
            day.setDate(daySchema.date());
            day.addDescription("en", daySchema.description());
            day.setTravelPlan(travelPlan);

            // Add attractions for this day
            for (AttractionSchema attractionSchema : daySchema.attractions()) {
                Attraction attraction = new Attraction();
                attraction.addName("en", attractionSchema.name());
                attraction.addDescription("en", attractionSchema.description());
                attraction.setVisitOrder(attractionSchema.visitingOrder());

                // Enrich with Google Maps data
                googleMapsService.searchPlace(attractionSchema.name() + " " + request.getDestination())
                        .ifPresent(placeResult -> {
                            // Set coordinates
                            googleMapsService.getLatitude(placeResult)
                                    .ifPresent(attraction::setLatitude);
                            googleMapsService.getLongitude(placeResult)
                                    .ifPresent(attraction::setLongitude);

                            // Set rating and user rating count
                            attraction.setAverageRating((double) placeResult.rating);
                            attraction.setNumberOfUserRatings(placeResult.userRatingsTotal);

                            attraction.setGooglePlacesId(placeResult.placeId);

                            googleMapsService.getOpeningHours(placeResult)
                                    .ifPresent(hours -> {
                                        System.out.println("Opening hours: " + Arrays.toString(hours));
                                    });

                            // Get and store a photo
                            googleMapsService.getRandomImageFromTopNPhotos(placeResult, 3)
                                    .ifPresent(imageBytes -> {
                                        s3StorageService.uploadFile(imageBytes, "image/jpeg", "jpg")
                                                .ifPresent(attraction::setImageFileName);
                                    });

                            // Get average time spent at the place by visitirs based on Google Maps data
                            googleTimeSpentService.getTimeSpent(googleMapsService.getName(placeResult),
                                            googleMapsService.getAddress(placeResult)
                                    )
                                    .ifPresent(attraction::setVisitDuration);
                        });

                day.addAttraction(attraction);
                attraction.setTravelPlanDay(day);
            }

            travelPlan.addTravelPlanDay(day);
        }

        // Translate into other languages
        translateDestinationDescriptionSchema(description, travelPlan);
        translateTravelPlanSchema(travelPlanSchema, travelPlan);

        // Associate trip with the current user - fail if user cannot be found
        User currentUser = userProfileService.getCurrentUser();

        if (currentUser.getGenerationsNumber() == null) {
            currentUser.setGenerationsNumber(1L);
        } else {
            currentUser.setGenerationsNumber(currentUser.getGenerationsNumber() + 1);
        }

        travelPlan.setCreatedAt(Instant.now());

        currentUser.addTravelPlan(travelPlan);
        userRepository.save(currentUser);

        return travelPlan.getId();
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

    private TravelPlanSchema generateTravelPlan(int tripDuration, String destination,
                                                LocalDateTime startDate, LocalDateTime endDate) {
        try {
            return chatClient.prompt()
                    .system(SYSTEM_PROMPT)
                    .user("Generate a detailed daily itinerary for a " + tripDuration + " day trip to " +
                            destination + " from " + startDate + " to " + endDate)
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

    private void translateDestinationDescriptionSchema(
            DestinationDescriptionSchema destinationDescriptionSchema, TravelPlan travelPlan
    ) {
        Optional<String> destinationDescriptionSchemaJson = convertToJson(destinationDescriptionSchema);

        if (destinationDescriptionSchemaJson.isEmpty()) {
            logger.error("Failed to convert DestinationDescriptionSchema to JSON, falling back to English");

            for (Language language : Language.values()) {
                if (language == Language.ENGLISH) continue;
                setDestinationDescriptionSchemaInTravelPlan(
                        travelPlan,
                        destinationDescriptionSchema,
                        language
                );
            }
            return;
        }

        for (Language language : Language.values()) {
            if (language == Language.ENGLISH) continue;
            String languageName = language.getName();

            try {
                String safeJson = destinationDescriptionSchemaJson.get().replace("{", "rightCurlyBrace")
                        .replace("}", "leftCurlyBrace")
                        .replace("[", "leftSquareBracket")
                        .replace("]", "rightSquareBracket");

                DestinationDescriptionSchema translatedSchema = chatClient.prompt()
                        .system("You are responsible for translating the description of travel plans.")
                        .user("Translate this travel plan description from English to " + languageName + ":\n" + safeJson)
                        //.user(prompt)
                        .call()
                        .entity(DestinationDescriptionSchema.class);

                setDestinationDescriptionSchemaInTravelPlan(
                        travelPlan,
                        translatedSchema,
                        language
                );
            } catch (Exception e) {
                logger.error("Failed to translate travel plan description to {}: {}", languageName, e.getMessage());
                // Fall back to English values by using the original schema
                setDestinationDescriptionSchemaInTravelPlan(
                        travelPlan,
                        destinationDescriptionSchema,
                        language
                );
            }
        }
    }

    private void translateTravelPlanSchema(
            TravelPlanSchema travelPlanSchema, TravelPlan travelPlan
    ) {
        Optional<String> travelPlanSchemaJson = convertToJson(travelPlanSchema);

        if (travelPlanSchemaJson.isEmpty()) {
            logger.error("Failed to convert TravelPlanSchema to JSON, falling back to English");

            for (Language language : Language.values()) {
                if (language == Language.ENGLISH) continue;
                setTravelPlanSchemaInTravelPlan(
                        travelPlan,
                        travelPlanSchema,
                        language
                );
            }
            return;
        }

        for (Language language : Language.values()) {
            if (language == Language.ENGLISH) continue;
            String languageName = language.getName();

            try {
                String safeJson = travelPlanSchemaJson.get().replace("{", "rightCurlyBrace")
                        .replace("}", "leftCurlyBrace")
                        .replace("[", "leftSquareBracket")
                        .replace("]", "rightSquareBracket");

                TravelPlanSchema translatedSchema = chatClient.prompt()
                        .system("You are responsible for translating travel itineraries.")
                        .user("Translate this travel itinerary from English to " + languageName +
                                ". Keep the exact same structure and maintain all dates and numbers:\n" +
                                safeJson)
                        .call()
                        .entity(TravelPlanSchema.class);

                setTravelPlanSchemaInTravelPlan(
                        travelPlan,
                        translatedSchema,
                        language
                );
            } catch (Exception e) {
                logger.error("Failed to translate travel plan to {}: {}", languageName, e.getMessage());
                // Fall back to English values by using the original schema
                setTravelPlanSchemaInTravelPlan(
                        travelPlan,
                        travelPlanSchema,
                        language
                );
            }
        }
    }

    private Optional<String> convertToJson(Object object) {
        ObjectMapper objectMapper = new ObjectMapper();
        // Register the Java 8 date/time module
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
