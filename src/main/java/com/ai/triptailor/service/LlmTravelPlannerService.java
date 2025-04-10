package com.ai.triptailor.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class LlmTravelPlannerService {
    private final S3StorageService s3StorageService;
    private final GoogleTimeSpentService googleTimeSpentService;

    @Autowired
    public LlmTravelPlannerService(
            S3StorageService s3StorageService,
            GoogleTimeSpentService googleTimeSpentService
    ) {
        this.s3StorageService = s3StorageService;
        this.googleTimeSpentService = googleTimeSpentService;
    }
}
