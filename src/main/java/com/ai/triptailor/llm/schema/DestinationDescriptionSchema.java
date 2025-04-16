package com.ai.triptailor.llm.schema;

public class DestinationDescriptionSchema {
    public static final String schema = """
    {
        "type": "object",
        "properties": {
            "aboutThePlace": {
                "type": "string",
                "description": "About the place in at least 50 words"
            },
            "placeHistory": {
                "type": "string",
                "description": "History of the place in at least 50 words"
            },
            "bestTimeToVisit": {
                "type": "string",
                "description": "Best time to visit"
            },
            "localCuisineRecommendations": {
                "type": "array",
                "description": "Local Cuisine Recommendations (at least 5 items)",
                "items": { "type": "string" }
            }
        },
        "required": [
            "aboutThePlace",
            "placeHistory",
            "bestTimeToVisit",
            "localCuisineRecommendations"
        ]
    }
    """;
}
