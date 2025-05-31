package com.ai.triptailor.service;

import com.ai.triptailor.exception.NearbyPlacesSummaryException;
import com.ai.triptailor.llm.enums.Language;
import com.ai.triptailor.request.NearbyPlacesSummaryRequest;
import com.ai.triptailor.response.AttractionResponse;
import com.ai.triptailor.response.NearbyPlacesSummaryResponse;
import com.google.maps.GeoApiContext;
import com.google.maps.GeocodingApi;
import com.google.maps.PlacesApi;
import com.google.maps.errors.ApiException;
import com.google.maps.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.stereotype.Service;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
public class NearbyPlacesSummaryService {
    private static final Logger logger = LoggerFactory.getLogger(NearbyPlacesSummaryService.class);

    private final GoogleTimeSpentService googleTimeSpentService;
    private final ChatClient chatClient;
    private final GeoApiContext geoApiContext;
    private final S3StorageService s3StorageService;

    public NearbyPlacesSummaryService(GoogleTimeSpentService googleTimeSpentService,
                                      ChatClient.Builder chatClientBuilder,
                                      GeoApiContext geoApiContext,
                                      S3StorageService s3StorageService) {
        this.googleTimeSpentService = googleTimeSpentService;
        this.chatClient = chatClientBuilder.build();
        this.geoApiContext = geoApiContext;
        this.s3StorageService = s3StorageService;
    }

    public NearbyPlacesSummaryResponse getNearbyPlacesSummary(NearbyPlacesSummaryRequest request) {
        try {
            LatLng location = new LatLng(request.getLatitude(), request.getLongitude());
            Optional<Language> languageOpt = Language.fromCodeOptional(request.getLanguage());
            Language language = languageOpt.orElse(Language.ENGLISH);
            String locationName = getLocationName(location);
            if (locationName == null) {
                throw new NearbyPlacesSummaryException("Could not determine location name");
            }

            PlacesSearchResult[] placesResults = findNearbyPointsOfInterest(
                    request.getLatitude(),
                    request.getLongitude(),
                    request.getRadiusMeters(),
                    "tourist_attraction",
                    language
            );

            int maxAttractions = Math.min(request.getMaxAttractions(), placesResults.length);
            PlacesSearchResult[] limitedResults = Arrays.copyOf(placesResults, maxAttractions);

            List<CompletableFuture<AttractionResponse>> attractionFutures = Arrays.stream(limitedResults)
                    .map(place -> processAttraction(place, language))
                    .toList();

            CompletableFuture.allOf(attractionFutures.toArray(new CompletableFuture[0])).join();

            List<AttractionResponse> attractions = attractionFutures.stream()
                    .map(CompletableFuture::join)
                    .filter(Objects::nonNull)
                    .collect(Collectors.toList());

            if (attractions.isEmpty()) {
                logger.warn("No attractions found near location: {}", locationName);
                throw new NearbyPlacesSummaryException("No attractions found near the specified location");
            }

            for (int i = 0; i < attractions.size(); i++) {
                attractions.get(i).setVisitOrder(i + 1);
            }

            NearbyPlacesSummaryResponse response = new NearbyPlacesSummaryResponse();
            response.setDestination(locationName);
            response.setAttractions(attractions);

            return response;
        } catch (Exception e) {
            logger.error("Error getting nearby places summary");
            throw new NearbyPlacesSummaryException("Error finding nearby places: " + e.getMessage(), e);
        }
    }

    private String getLocationName(LatLng location) throws InterruptedException, IOException, ApiException {
        GeocodingResult[] results = GeocodingApi.reverseGeocode(geoApiContext, location).await();
        if (results == null || results.length == 0) {
            return null;
        }

        for (AddressComponent component : results[0].addressComponents) {
            for (AddressComponentType type : component.types) {
                if (type == AddressComponentType.LOCALITY ||
                        type == AddressComponentType.NEIGHBORHOOD ||
                        type == AddressComponentType.ADMINISTRATIVE_AREA_LEVEL_1) {
                    return component.longName;
                }
            }
        }
        return results[0].formattedAddress;
    }

    private PlacesSearchResult[] findNearbyPointsOfInterest(double latitude, double longitude, int radiusInMeters,
                                                            String type, Language language)
            throws ApiException, InterruptedException, IOException {
        LatLng location = new LatLng(latitude, longitude);

        PlacesSearchResponse response = PlacesApi.nearbySearchQuery(geoApiContext, location)
                .radius(radiusInMeters)
                .language(language.getCode())
                .type(PlaceType.valueOf(type.toUpperCase()))
                .await();

        return response.results;
    }

    private CompletableFuture<AttractionResponse> processAttraction(PlacesSearchResult place, Language language) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                AttractionResponse attraction = new AttractionResponse();
                attraction.setName(place.name);
                attraction.setGooglePlacesId(place.placeId);

                if (place.geometry != null && place.geometry.location != null) {
                    attraction.setLatitude(place.geometry.location.lat);
                    attraction.setLongitude(place.geometry.location.lng);
                }

                attraction.setAverageRating(place.rating);
                attraction.setNumberOfUserRatings(place.userRatingsTotal);

                String description = generateAttractionDescription(place.name, place.vicinity, language);
                attraction.setDescription(description);

                googleTimeSpentService.getTimeSpent(place.name, place.vicinity)
                        .ifPresent(attraction::setVisitDuration);

                if (place.photos != null && place.photos.length > 0) {
                    String photoReference = place.photos[0].photoReference;
                    byte[] imageBytes = PlacesApi.photo(geoApiContext, photoReference)
                            .maxWidth(8000)
                            .await()
                            .imageData;

                    Optional<String> s3Key = s3StorageService.uploadFile(imageBytes, "image/jpeg", "jpg");
                    s3Key.flatMap(s3StorageService::generatePresignedUrl).ifPresent(attraction::setImageUrl);
                }

                return attraction;
            } catch (Exception e) {
                logger.warn("Error processing attraction {}: {}", place.name, e.getMessage());
                return null;
            }
        });
    }

    private String generateAttractionDescription(String name, String vicinity, Language language) {
        try {
            String promptText = String.format(
                    "Generate a detailed, engaging summary of %s located in %s. " +
                            "Include what makes this place special, any historical significance, " +
                            "and why travelers should visit. Keep it concise but informative, max 10 sentences. " +
                            "The summary should be in %s.",
                    name, vicinity, language.getName());

            return chatClient.prompt()
                    .system("You are a knowledgeable travel guide that provides interesting summaries of attractions.")
                    .user(promptText)
                    .call()
                    .content();
        } catch (Exception e) {
            logger.warn("Error generating description for {}: {}", name, e.getMessage());
            return "Information about " + name + " is not available at this time.";
        }
    }
}
