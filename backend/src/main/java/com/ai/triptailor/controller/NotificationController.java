package com.ai.triptailor.controller;

import com.ai.triptailor.request.BulkNotificationRequest;
import com.ai.triptailor.service.NotificationService;
import jakarta.validation.Valid;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBooleanProperty;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@ConditionalOnBooleanProperty(name = "firebase.enabled")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

//    @PostMapping("/bulk-send")
//    @PreAuthorize("hasRole('ADMIN')")
//    public ResponseEntity<Map<String, Object>> sendBulkNotifications(@Valid @RequestBody BulkNotificationRequest request) {
//        Map<String, Object> result = notificationService.sendNotificationToUsers(request);
//        return ResponseEntity.ok(result);
//    }
}