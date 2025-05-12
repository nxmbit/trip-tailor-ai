package com.ai.triptailor.llm.schema;

import org.springframework.context.annotation.Description;

import java.time.LocalDateTime;
import java.util.List;

public record TravelPlanDaySchema(
        @Description("Short description of the day")
        String description,

        @Description("Date of the day")
        LocalDateTime date,

        @Description("Day number in the travel plan")
        int dayNumber,

        @Description("List of attractions for the day")
        List<AttractionSchema> attractions
) {
}
