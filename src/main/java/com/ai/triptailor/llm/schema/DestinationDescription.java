package com.ai.triptailor.llm.schema;

import org.springframework.context.annotation.Description;

public record DestinationDescription(
        @Description("About the place in at least 50 words")
        String aboutThePlace,

        @Description("History of the place in at least 50 words")
        String placeHistory,

        @Description("Best time to visit")
        String bestTimeToVisit,

        @Description("Local Cuisine Recommendations (at least 5 items)")
        String[] localCuisineRecommendations
) {}