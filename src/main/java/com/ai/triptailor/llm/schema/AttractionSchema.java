package com.ai.triptailor.llm.schema;

import org.springframework.context.annotation.Description;

public record AttractionSchema(
        @Description("The numerical order in which this attraction will be visited (1, 2, 3, etc.)")
        int visitingOrder,

        @Description("Name of the attraction")
        String name,

        @Description("Short description of the attraction")
        String description
) {
}
