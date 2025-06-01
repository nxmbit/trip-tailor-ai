package com.ai.triptailor.service;

import com.ai.triptailor.model.FcmToken;
import com.ai.triptailor.model.User;
import com.ai.triptailor.repository.FcmTokenRepository;
import com.ai.triptailor.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class FcmTokenService {
    private final FcmTokenRepository fcmTokenRepository;
    private final UserRepository userRepository;

    public FcmTokenService(FcmTokenRepository fcmTokenRepository, UserRepository userRepository) {
        this.fcmTokenRepository = fcmTokenRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public FcmToken saveToken(String token, Long userId) {
        Optional<FcmToken> existingToken = fcmTokenRepository.findByTokenAndUserId(token, userId);

        if (existingToken.isPresent()) {
            return existingToken.get();
        } else {
            // Create new token for this user
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + userId));
            FcmToken newToken = new FcmToken(token, user);
            return fcmTokenRepository.save(newToken);
        }
    }

    public List<FcmToken> getTokensByUserId(Long userId) {
        return fcmTokenRepository.findByUserId(userId);
    }

    @Transactional
    public void deleteToken(String token) {
        fcmTokenRepository.deleteByToken(token);
    }

    @Transactional
    public void deleteTokenForUser(String token, Long userId) {
        fcmTokenRepository.deleteByTokenAndUserId(token, userId);
    }
}