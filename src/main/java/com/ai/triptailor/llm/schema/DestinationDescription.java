package com.ai.triptailor.llm.schema;

import org.springframework.context.annotation.Description;

public record DestinationDescription(
        @Description("About the place in at least 50 words")
        String aboutTheDestination,

        @Description("History of the place in at least 50 words")
        String destinationHistory,

        @Description("Best time to visit")
        String bestTimeToVisit,

        @Description("Local Cuisine Recommendations (at least 5 items)")
        String[] localCuisineRecommendations
) {}