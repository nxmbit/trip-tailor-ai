package com.ai.triptailor.llm.tool;

import com.ai.triptailor.service.GoogleTimeSpentService;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class TimeSpentTool {
    private final GoogleTimeSpentService googleTimeSpentService;

    @Autowired
    public TimeSpentTool(GoogleTimeSpentService googleTimeSpentService) {
        this.googleTimeSpentService = googleTimeSpentService;
    }

//    @Tool(description = "Get the time in minutes spent usually spent at a place")
//    public int getTimeSpent(String placename) {
//        return googleTimeSpentService.getTimeSpent(placename);
//    }
}
