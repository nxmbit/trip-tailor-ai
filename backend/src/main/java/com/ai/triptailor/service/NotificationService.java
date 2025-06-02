package com.ai.triptailor.service;

import com.ai.triptailor.model.FcmToken;
import com.ai.triptailor.model.User;
import com.ai.triptailor.repository.UserRepository;
import com.ai.triptailor.request.BulkNotificationFilter;
import com.ai.triptailor.request.BulkNotificationRequest;
import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBooleanProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.*;

@Service
@ConditionalOnBooleanProperty(name = "firebase.enabled")
public class NotificationService {
    private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);

    private final FirebaseMessaging firebaseMessaging;
    private final FcmTokenService fcmTokenService;
    private final UserRepository userRepository;

    public NotificationService(FcmTokenService fcmTokenService, FirebaseApp firebaseApp,
                               UserRepository userRepository) {
        this.fcmTokenService = fcmTokenService;
        this.firebaseMessaging = FirebaseMessaging.getInstance(firebaseApp);
        this.userRepository = userRepository;
    }

    public void sendNotificationToUser(User user, String title, String body) {
        List<FcmToken> tokens = fcmTokenService.getTokensByUserId(user.getId());

        if (tokens.isEmpty()) {
            logger.warn("No FCM tokens found for user ID: {}", user.getId());
        }

        boolean anySuccess = false;
        for (FcmToken fcmToken : tokens) {
            try {
                Message message = buildMessage(fcmToken.getToken(), title, body);
                String responseId = firebaseMessaging.send(message);
                logger.debug("Successfully sent message: {} to token: {}", responseId, fcmToken.getToken());
                anySuccess = true;
            } catch (FirebaseMessagingException e) {
                handleFcmException(e, fcmToken);
            }
        }
    }

    public Map<String, Object> sendNotificationToUsers(BulkNotificationRequest request) {
        List<User> users = getUsersByFilter(request.getUserFilter(), request.getFilterParams());
        logger.info("Sending notifications to {} users", users.size());

        int totalUsers = users.size();
        int successCount = 0;
        Set<String> processedTokens = new HashSet<>();

        for (User user : users) {
            List<FcmToken> tokens = fcmTokenService.getTokensByUserId(user.getId());

            boolean userNotified = false;
            for (FcmToken token : tokens) {
                // Skip if this token has already been used (multiple accounts on one device)
                if (processedTokens.contains(token.getToken())) {
                    continue;
                }

                try {
                    Message message = buildMessage(token.getToken(), request.getTitle(), request.getMessage());
                    firebaseMessaging.send(message);
                    processedTokens.add(token.getToken());
                    userNotified = true;
                } catch (FirebaseMessagingException e) {
                    handleFcmException(e, token);
                }
            }

            if (userNotified) {
                successCount++;
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("totalUsers", totalUsers);
        result.put("successfullyNotified", successCount);
        result.put("uniqueDevices", processedTokens.size());

        return result;
    }

    private List<User> getUsersByFilter(String filterCode, Map<String, Object> params) {
        BulkNotificationFilter filter = BulkNotificationFilter.fromCode(filterCode);

        switch (filter) {
            case LAST_PLAN_OLDER_THAN:
                int days = params != null && params.containsKey("days") ?
                        Integer.parseInt(params.get("days").toString()) : 5;
                Instant cutoffDate = LocalDateTime.now().minusDays(days)
                        .toInstant(ZoneOffset.UTC);
                return findUsersWithLastPlanBefore(cutoffDate);
            case NO_PLANS:
                return findUsersWithNoPlans();
            case ALL_USERS:
            default:
                return userRepository.findAll();
        }
    }

    private Message buildMessage(String token, String title, String body) {
        return Message.builder()
                .setToken(token)
                .setNotification(Notification.builder()
                        .setTitle(title)
                        .setBody(body)
                        .build())
                .build();
    }

    private void handleFcmException(FirebaseMessagingException e, FcmToken token) {
        String errorCode = e.getErrorCode().toString();
        logger.info("Firebase error: {} for token: {}", errorCode, token.getToken());

        if (isInvalidTokenError(errorCode)) {
            logger.info("Removing invalid token: {}", token.getToken());
            fcmTokenService.deleteTokenForUser(token.getToken(), token.getUser().getId());
        }
    }

    private boolean isInvalidTokenError(String errorCode) {
        return errorCode.equals("UNREGISTERED") ||
                errorCode.equals("INVALID_ARGUMENT") ||
                errorCode.equals("NOT_FOUND");
    }

    public List<User> findUsersWithLastPlanBefore(Instant cutoffDate) {
        return userRepository.findUsersWithLastPlanBefore(cutoffDate);
    }

    public List<User> findUsersWithNoPlans() {
        return userRepository.findByTravelPlansIsEmpty();
    }

    @PostConstruct
    public void runScheduledNotificationsOnStartup() {
        logger.info("Sending notifications on startup");

        sendInactivityReminder();
        sendDailyTripPlanReminder();
        sendNoTripPlanReminder();
    }

    @Scheduled(cron = "0 0 15 * * *")
    public void sendInactivityReminder() {
        logger.info("Sending scheduled inactivity reminder notifications");
        BulkNotificationRequest request = new BulkNotificationRequest();
        request.setTitle("Missing you!");
        request.setMessage("It's been a while since you created a trip plan. Come back and plan your next adventure!");
        request.setUserFilter("lastPlanOlderThan");

        Map<String, Object> params = new HashMap<>();
        params.put("days", 7);
        request.setFilterParams(params);

        Map<String, Object> result = sendNotificationToUsers(request);
        logger.info("Sent notifications to {} users on {} unique devices",
                result.get("successfullyNotified"), result.get("uniqueDevices"));
    }

    @Scheduled(cron = "0 0 18 * * *")
    public void sendDailyTripPlanReminder() {
        logger.info("Sending daily trip plan reminder notifications");
        BulkNotificationRequest request = new BulkNotificationRequest();
        request.setTitle("Plan your next trip!");
        request.setMessage("Don't forget to plan your next adventure with us. Start creating your trip today!");
        request.setUserFilter("allUsers");

        Map<String, Object> result = sendNotificationToUsers(request);
        logger.info("Sent daily reminders to {} users on {} unique devices",
                result.get("successfullyNotified"), result.get("uniqueDevices"));
    }

    @Scheduled(cron = "0 0 11 * * *")
    public void sendNoTripPlanReminder() {
        logger.info("Sending no trip plan reminder notifications");
        BulkNotificationRequest request = new BulkNotificationRequest();
        request.setTitle("No trip plans yet?");
        request.setMessage("You haven't created any trip plans yet. Start planning your next adventure with us!");
        request.setUserFilter("noPlans");

        Map<String, Object> result = sendNotificationToUsers(request);
        logger.info("Sent no trip plan reminders to {} users on {} unique devices",
                result.get("successfullyNotified"), result.get("uniqueDevices"));
    }

}
