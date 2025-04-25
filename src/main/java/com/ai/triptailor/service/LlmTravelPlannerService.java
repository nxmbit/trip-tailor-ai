package com.ai.triptailor.service;

import com.ai.triptailor.model.User;
import com.ai.triptailor.repository.TripRepository;
import com.ai.triptailor.repository.UserRepository;
import com.ai.triptailor.request.GenerateTravelPlanRequestDto;
import com.ai.triptailor.llm.schema.DestinationDescription;
import com.ai.triptailor.model.Trip;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;

@Service
public class LlmTravelPlannerService {
    private static final Logger logger = LoggerFactory.getLogger(LlmTravelPlannerService.class);

    private final S3StorageService s3StorageService;
    private final GoogleTimeSpentService googleTimeSpentService;
    private final GoogleMapsService googleMapsService;
    private final ChatClient chatClient;
    private final UserProfileService userProfileService;
    private final TripRepository tripRepository;
    private final UserRepository userRepository;

    private final String SYSTEM_PROMPT = "You are a travel planner.";

    @Autowired
    public LlmTravelPlannerService(
            S3StorageService s3StorageService,
            GoogleTimeSpentService googleTimeSpentService,
            GoogleMapsService googleMapsService,
            ChatClient.Builder chatClientBuilder,
            UserProfileService userProfileService,
            TripRepository tripRepository,
            UserRepository userRepository
    ) {
        this.s3StorageService = s3StorageService;
        this.googleTimeSpentService = googleTimeSpentService;
        this.googleMapsService = googleMapsService;
        this.chatClient = chatClientBuilder.build();
        this.userProfileService = userProfileService;
        this.tripRepository = tripRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public Trip generateTravelPlan(@Valid GenerateTravelPlanRequestDto request) {
        Trip trip = new Trip();
        trip.addDestination("en", request.getDestination());
        trip.setTripStartDate(request.getStartDate());
        trip.setTripEndDate(request.getEndDate());

        // Calculate trip duration in days
        Duration duration = Duration.between(trip.getTripStartDate(), trip.getTripEndDate());
        long days = (int) duration.toDays();

        // Search for place using Google Maps API, if not found throw an exception
        var placesSearchResult = googleMapsService.searchPlace(request.getDestination());
        if (placesSearchResult.isEmpty()) {
            throw new RuntimeException("Destination not found");
        }
        var place = placesSearchResult.get();
        trip.setGooglePlacesId(place.placeId);

        // For more variety across different travel plans to the same place,
        // get random photo from top 5 photo search results
        googleMapsService.getRandomImageFromTopNPhotos(place, 5)
                .ifPresent(imageBytes -> {
                    s3StorageService.uploadFile(imageBytes, "image/jpeg", "jpg")
                            .ifPresent(trip::setImageFileName);
                });

        // Generate trip description
        DestinationDescription description = chatClient.prompt()
                .system(SYSTEM_PROMPT)
                .user("Generate a description about the travel destination " + request.getDestination())
                .call()
                .entity(DestinationDescription.class);

        // TODO: error handling
        trip.addDescription("en", description.aboutTheDestination());
        trip.addBestTimeToVisit("en", description.bestTimeToVisit());
        trip.addLocalCuisineRecommendations("en", description.localCuisineRecommendations());
        trip.addDestinationHistory("en", description.destinationHistory());

        // Generate daily itinerary

        // Associate trip with the current user - fail if user cannot be found
        User currentUser = userProfileService.getCurrentUser();

        if (currentUser.getGenerationsNumber() == null) {
            currentUser.setGenerationsNumber(1L);
        } else {
            currentUser.setGenerationsNumber(currentUser.getGenerationsNumber() + 1);
        }

        currentUser.addTrip(trip);
        userRepository.save(currentUser);

        return trip;
    }
}
