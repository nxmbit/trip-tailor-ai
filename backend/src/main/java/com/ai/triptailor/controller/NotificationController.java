package com.ai.triptailor.controller;

import com.ai.triptailor.model.User;
import com.ai.triptailor.request.NotificationRequest;
import com.ai.triptailor.response.NotificationResponse;
import com.ai.triptailor.service.NotificationService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @PostMapping("/send")
    public ResponseEntity<NotificationResponse> sendNotification(@RequestBody NotificationRequest request) {
        NotificationResponse response = new NotificationResponse();

        try {
            notificationService.sendNotification(request);
            response.setStatus(200);
            response.setMessage("Notification sent successfully");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.setStatus(500);
            response.setMessage("Failed to send notification: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}