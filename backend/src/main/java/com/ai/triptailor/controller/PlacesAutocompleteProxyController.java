package com.ai.triptailor.controller;

import com.ai.triptailor.service.PlacesAutocompleteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/autocomplete")
public class PlacesAutocompleteProxyController {

    private final PlacesAutocompleteService placesAutocompleteService;

    @Autowired
    public PlacesAutocompleteProxyController(PlacesAutocompleteService placesAutocompleteService) {
        this.placesAutocompleteService = placesAutocompleteService;
    }

    @GetMapping(value = "/proxy", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> proxyAutocompleteRequest(@RequestParam Map<String, String> allParams) {
        String response = placesAutocompleteService.proxyAutocompleteRequest(allParams);
        return ResponseEntity.ok(response);
    }
}