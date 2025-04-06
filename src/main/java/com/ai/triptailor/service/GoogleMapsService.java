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

@Service
public class GoogleMapsService {
    private final GeoApiContext geoApiContext;

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

    public String getPlaceId(PlacesSearchResult place) {
        return place.placeId;
    }

    public String getAddress(PlacesSearchResult place) {
        return place.formattedAddress;
    }

    public String getName(PlacesSearchResult place) {
        return place.name;
    }

    public double getLatitude(PlacesSearchResult place) {
        return place.geometry.location.lat;
    }

    public double getLongitude(PlacesSearchResult place) {
        return place.geometry.location.lng;
    }

    //TODO: implement getting opening and closing hours


}
