package com.ai.triptailor.service;

import com.ai.triptailor.model.User;
import com.ai.triptailor.repository.UserRepository;
import com.ai.triptailor.response.UserProfileResponseDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserProfileService {

    private final UserRepository userRepository;

    @Autowired
    public UserProfileService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserProfileResponseDto getUserProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return new UserProfileResponseDto(
                user.getEmail(),
                user.getUsername(),
                user.getProfileImageUrl()
        );
    }
}