package com.ai.triptailor.llm.schema;

import org.springframework.context.annotation.Description;
import java.util.List;

public record TravelPlanSchema(
        @Description("List of days in the travel plan")
        List<TravelPlanDaySchema> days
) {
}