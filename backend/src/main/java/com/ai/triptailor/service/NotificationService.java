package com.ai.triptailor.service;

import com.ai.triptailor.model.FcmToken;
import com.ai.triptailor.model.User;
import com.ai.triptailor.request.NotificationRequest;
import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class NotificationService {
    private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);

    private final FirebaseMessaging firebaseMessaging;
    private final FirebaseApp firebaseApp;
    private final FcmTokenService fcmTokenService;

    public NotificationService(FcmTokenService fcmTokenService, FirebaseApp firebaseApp) {
        this.firebaseApp = firebaseApp;
        this.fcmTokenService = fcmTokenService;
        this.firebaseMessaging = FirebaseMessaging.getInstance(firebaseApp);
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

    public void sendNotification(NotificationRequest request) {
        try {
            Message message = buildMessage(request.getToken(), request.getTitle(), request.getMessage());
            String responseId = firebaseMessaging.send(message);
            logger.info("Successfully sent message: {}", responseId);
        } catch (FirebaseMessagingException e) {
            handleFcmException(e, request.getToken());
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
        logger.error("Firebase error: {} for token: {}", errorCode, token.getToken());

        if (isInvalidTokenError(errorCode)) {
            logger.info("Removing invalid token: {}", token.getToken());
            fcmTokenService.deleteTokenForUser(token.getToken(), token.getUser().getId());
        }
    }

    private void handleFcmException(FirebaseMessagingException e, String tokenString) {
        String errorCode = e.getErrorCode().toString();
        logger.error("Firebase error: {} for token: {}", errorCode, tokenString);

        if (isInvalidTokenError(errorCode)) {
            logger.info("Removing invalid token: {}", tokenString);
            fcmTokenService.deleteToken(tokenString);
        }
    }

    private boolean isInvalidTokenError(String errorCode) {
        return errorCode.equals("UNREGISTERED") ||
                errorCode.equals("INVALID_ARGUMENT") ||
                errorCode.equals("NOT_FOUND");
    }
}
