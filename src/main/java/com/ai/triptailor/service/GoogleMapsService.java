package com.ai.triptailor.service;

import com.ai.triptailor.exception.GoogleMapsServiceException;
import com.google.maps.GeoApiContext;
import com.google.maps.PlacesApi;
import com.google.maps.errors.ApiException;
import com.google.maps.model.PlaceDetails;
import com.google.maps.model.PlacesSearchResponse;
import com.google.maps.model.PlacesSearchResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.Optional;
import java.util.Random;

@Service
public class GoogleMapsService {
    private final GeoApiContext geoApiContext;
    private final Random random = new Random();

    @Autowired
    public GoogleMapsService(GeoApiContext geoApiContext) {
        this.geoApiContext = geoApiContext;
    }

    public Optional<PlacesSearchResult> searchPlace(String placeName) {
        try {
            PlacesSearchResponse response = PlacesApi.textSearchQuery(geoApiContext, placeName).await();
            if (response.results != null && response.results.length > 0) {
                return Optional.of(response.results[0]);
            } else {
                return Optional.empty();
            }
        } catch (ApiException | InterruptedException | IOException e) {
            throw new GoogleMapsServiceException("Error searching for place: " + e.getMessage(), e);
        }
    }

    private Optional<byte[]> getImageBytesFromReference(String photoReference) {
        try {
            return Optional.of(PlacesApi.photo(geoApiContext, photoReference)
                    .maxWidth(4096)
                    .await()
                    .imageData
            );

        } catch (ApiException | InterruptedException | IOException e) {
            throw new GoogleMapsServiceException("Error fetching place image: " + e.getMessage(), e);
        }
    }

    public Optional<byte[]> getFirstImageFromPlace(PlacesSearchResult place) {
        if (place.photos != null && place.photos.length > 0) {
            String photoReference = place.photos[0].photoReference;
            return getImageBytesFromReference(photoReference);
        } else {
            return Optional.empty();
        }
    }

    public Optional<byte[]> getRandomImageFromTopNPhotos(PlacesSearchResult place, int n) {
        if (n <= 0) throw new IllegalArgumentException("Parameter n must be positive");

        if (place.photos != null && place.photos.length > 0) {
            int randomIndex = random.nextInt(Math.min(n, place.photos.length));
            String photoReference = place.photos[randomIndex].photoReference;
            return getImageBytesFromReference(photoReference);
        } else {
            return Optional.empty();
        }
    }

    public double getRating(PlacesSearchResult place) {
        return place.rating;
    }

    public int getUserRatingsTotal(PlacesSearchResult place) {
        return place.userRatingsTotal;
    }

    public String getPlaceId(PlacesSearchResult place) {
        return place.placeId;
    }

    public String getAddress(PlacesSearchResult place) {
        return place.formattedAddress;
    }

    public String getName(PlacesSearchResult place) {
        return place.name;
    }

    public Optional<Double> getLatitude(PlacesSearchResult place) {
        if (place.geometry != null && place.geometry.location != null) {
            return Optional.of(place.geometry.location.lat);
        }
        return Optional.empty();
    }

    public Optional<Double> getLongitude(PlacesSearchResult place) {
        if (place.geometry != null && place.geometry.location != null) {
            return Optional.of(place.geometry.location.lng);
        }
        return Optional.empty();
    }

    //TODO when finding open hours, check for special cases like holidays or special events during the users stay
    public Optional<String[]> getOpeningHours(PlacesSearchResult place) {
        if (place.openingHours != null && place.openingHours.weekdayText != null) {
            return Optional.of(place.openingHours.weekdayText);
        }
        return Optional.empty();
    }


}
