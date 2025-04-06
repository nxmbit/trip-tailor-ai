package com.ai.triptailor.service;

import com.ai.triptailor.exception.GoogleTimeSpentServiceException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class GoogleTimeSpentService {
    private static final Logger logger = LoggerFactory.getLogger(GoogleTimeSpentService.class);
    private static final String USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36";
    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Extracts "People typically spend X time here" information from Google search results
     * for a given attraction.
     *
     * @param name The name of the attraction
     * @param address The address of the attraction
     * @return The time usually spent at the attraction in minutes
     */
    public Optional<Integer> getTimeSpent(String name, String address) {
        try {
            String placeIdentifier = name + " " + address;
            String encodedQuery = URLEncoder.encode(placeIdentifier, StandardCharsets.UTF_8.toString());

            String searchUrl = "https://www.google.com/search?tbm=map&tch=1&hl=en&q=" + encodedQuery;
            logger.debug("Search URL: {}", searchUrl);

            URL url = new URL(searchUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("User-Agent", USER_AGENT);

            int responseCode = connection.getResponseCode();
            if (responseCode != 200) {
                logger.error("HTTP error code: {}", responseCode);
                return Optional.empty();
            }

            StringBuilder response = new StringBuilder();
            BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
            reader.close();

            String data = response.toString();

            // Split to get JSON part
            String[] parts = data.split("/\\*\"\"\\*/");
            if (parts.length == 0) {
                throw new GoogleTimeSpentServiceException("Failed to parse Google response - no parts found");
            }
            data = parts[0];

            // Find end of JSON
            int jend = data.lastIndexOf("}");
            if (jend < 0) {
                throw new GoogleTimeSpentServiceException("Failed to find end of JSON in Google response");
            }
            data = data.substring(0, jend + 1);

            // Parse JSON
            JsonNode jdata = objectMapper.readTree(data).get("d");
            String jsonStr = jdata.asText().substring(4); // Remove first 4 chars

            JsonNode jsonData = objectMapper.readTree(jsonStr);

            // Extract info using indexGet
            JsonNode info = indexGet(jsonData, 0, 1, 0, 14);
            if (info == null) {
                throw new GoogleTimeSpentServiceException("Could not find expected data at index path");
            }

            JsonNode timeSpentNode = indexGet(info, 117, 0);
            if (timeSpentNode == null || !timeSpentNode.isTextual()) {
                return Optional.empty();
            }

            String timeSpentText = timeSpentNode.asText();

            // Extract numbers using regex
            List<Double> nums = new ArrayList<>();
            Pattern pattern = Pattern.compile("\\d*\\.\\d+|\\d+");
            Matcher matcher = pattern.matcher(timeSpentText.replace(",", "."));

            while (matcher.find()) {
                nums.add(Double.parseDouble(matcher.group()));
            }

            if (nums.isEmpty()) {
                return Optional.empty();
            }

            // Check if contains hours or minutes
            boolean containsMin = timeSpentText.contains("min");
            boolean containsHour = timeSpentText.contains("hour") || timeSpentText.contains("hr");

            Double timeSpent = null;

            if (containsHour) {
                timeSpent = nums.get(0) * 60;
            } else if (containsMin) {
                timeSpent = nums.get(0);
            }

            if (timeSpent == null) {
                return Optional.empty();
            }

            return Optional.of(timeSpent.intValue());

        } catch (IOException e) {
            logger.error("Error fetching Google search results: {}", e.getMessage());
            return Optional.empty();
        } catch (GoogleTimeSpentServiceException e) {
            logger.error("Error processing Google search results to extract time spent: {}", e.getMessage());
            return Optional.empty();
        }
    }

    private JsonNode indexGet(JsonNode node, Object... indices) {
        try {
            JsonNode currentNode = node;

            for (Object index : indices) {
                int idx = (int) index;
                if (currentNode != null && currentNode.isArray() && idx < currentNode.size()) {
                    currentNode = currentNode.get(idx);
                } else {
                    return null;
                }
            }

            return currentNode;
        } catch (Exception e) {
            logger.error("Error accessing JSON index: {}", e.getMessage());
            return null;
        }
    }
}