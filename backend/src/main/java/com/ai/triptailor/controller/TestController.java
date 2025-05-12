package com.ai.triptailor.controller;

import com.ai.triptailor.service.GoogleMapsService;
import com.ai.triptailor.service.GoogleTimeSpentService;
import com.google.maps.model.PlacesSearchResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
public class TestController {

    @Autowired
    private GoogleMapsService googleMapsService;

    @GetMapping("/test")
    public String test() {
        return "Test endpoint is working!";
    }


    @PostMapping("/test/place")
    public ResponseEntity<?> testSearchPlace(@RequestBody Map<String, String> request) {
        String placeName = request.get("placeName");
        if (placeName == null || placeName.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "placeName is required"));
        }

        Optional<PlacesSearchResult> placeOpt = googleMapsService.searchPlace(placeName);

        if (placeOpt.isPresent()) {
            PlacesSearchResult place = placeOpt.get();
            Map<String, Object> response = new HashMap<>();
            response.put("name", googleMapsService.getName(place));
            response.put("address", googleMapsService.getAddress(place));
            response.put("placeId", googleMapsService.getPlaceId(place));
            response.put("lat", googleMapsService.getLatitude(place));
            response.put("lng", googleMapsService.getLongitude(place));
            response.put("hasPhotos", place.photos != null && place.photos.length > 0);

            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping(value = "/test/place/image", produces = MediaType.IMAGE_JPEG_VALUE)
    public ResponseEntity<byte[]> testPlaceImage(@RequestBody Map<String, String> request) {
        String placeName = request.get("placeName");
        if (placeName == null || placeName.isBlank()) {
            return ResponseEntity.badRequest().build();
        }

        Optional<PlacesSearchResult> placeOpt = googleMapsService.searchPlace(placeName);

        if (placeOpt.isPresent()) {
            PlacesSearchResult place = placeOpt.get();
            return googleMapsService.getFirstImageFromPlace(place)
                    .map(imageBytes -> ResponseEntity.ok()
                            .contentType(MediaType.IMAGE_JPEG)
                            .body(imageBytes))
                    .orElse(ResponseEntity.notFound().build());
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @Autowired
    private GoogleTimeSpentService googleTimeSpentService;

    @PostMapping("/test/time-spent")
    public ResponseEntity<?> testTimeSpent(@RequestBody Map<String, String> request) {
        String attractionName = request.get("attractionName");
        String location = request.get("location");

        if (attractionName == null || attractionName.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "attractionName is required"));
        }

        // Location is optional, but we'll use empty string if not provided
        if (location == null) {
            location = "";
        }

        Optional<Integer> timeSpentOpt = googleTimeSpentService.getTimeSpent(attractionName, location);

        if (timeSpentOpt.isPresent()) {
            int minutes = timeSpentOpt.get();

            // Format the time in a human-readable way
            String formattedTime = formatMinutes(minutes);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "attractionName", attractionName,
                    "location", location,
                    "minutes", minutes,
                    "formattedTime", formattedTime
            ));
        } else {
            return ResponseEntity.ok(Map.of(
                    "success", false,
                    "message", "No time spent information found for this attraction"
            ));
        }
    }

    /**
     * Formats minutes into a readable hours and minutes format
     */
    private String formatMinutes(int minutes) {
        int hours = minutes / 60;
        int mins = minutes % 60;

        if (hours > 0 && mins > 0) {
            return hours + " hour" + (hours > 1 ? "s" : "") + " " + mins + " min" + (mins > 1 ? "s" : "");
        } else if (hours > 0) {
            return hours + " hour" + (hours > 1 ? "s" : "");
        } else {
            return mins + " min" + (mins > 1 ? "s" : "");
        }
    }
}
