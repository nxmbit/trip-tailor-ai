package com.ai.triptailor.service;

import com.ai.triptailor.exception.GoogleMapsServiceException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Map;

@Service
public class PlacesAutocompleteService {
    @Value("${google.maps.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    public String proxyAutocompleteRequest(Map<String, String> queryParams) {
        try {
            UriComponentsBuilder builder = UriComponentsBuilder
                    .fromHttpUrl("https://maps.googleapis.com/maps/api/place/autocomplete/json")
                    .queryParam("key", apiKey);

            queryParams.forEach((key, value) -> {
                if (!key.equals("key")) {
                    builder.queryParam(key, value);
                }
            });

            ResponseEntity<String> response = restTemplate.getForEntity(
                    builder.build().toUriString(),
                    String.class
            );

            return response.getBody();
        } catch (Exception e) {
            throw new GoogleMapsServiceException("Error proxying Google Places API request: " + e.getMessage(), e);
        }
    }
}