package com.ai.triptailor.service;

import com.ai.triptailor.model.AuthProvider;
import com.ai.triptailor.model.User;
import com.ai.triptailor.model.UserPrincipal;
import com.ai.triptailor.repository.UserRepository;
import com.ai.triptailor.response.UserProfileResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import java.io.IOException;
import static com.ai.triptailor.util.ImageUtils.getExtensionFromContentType;

@Service
public class UserProfileService {

    private final UserRepository userRepository;
    private final S3StorageService s3StorageService;
    private final PasswordEncoder passwordEncoder;

    public UserProfileService(UserRepository userRepository, S3StorageService s3StorageService,
                              PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.s3StorageService = s3StorageService;
        this.passwordEncoder = passwordEncoder;
    }

    public UserProfileResponse getUserProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return new UserProfileResponse(
                user.getEmail(),
                user.getUsername(),
                s3StorageService.generatePresignedUrl(user.getProfileImageFilename())
                        .orElse(null),
                user.getAuthProvider()
        );
    }

    public User getCurrentUser() {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.getPrincipal() instanceof UserPrincipal userPrincipal) {
                return userRepository.findById(userPrincipal.getId())
                        .orElseThrow(() -> new RuntimeException("User not found"));
            }
            throw new RuntimeException("Not authenticated");
        } catch (Exception e) {
            throw new RuntimeException("Error retrieving current user", e);
        }
    }

    public UserProfileResponse updateProfileImage(Long userId, MultipartFile profileImage) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (profileImage.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Profile image is empty");
        }

        String contentType = profileImage.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "File is not an image");
        }

        try {
            String extension = getExtensionFromContentType(contentType)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported image type"));
            s3StorageService.uploadFile(profileImage.getBytes(), contentType, extension)
                    .ifPresent(user::setProfileImageFilename);

            userRepository.save(user);

            return new UserProfileResponse(
                    user.getEmail(),
                    user.getUsername(),
                    s3StorageService.generatePresignedUrl(user.getProfileImageFilename())
                            .orElse(null),
                    user.getAuthProvider()
            );
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error uploading image", e);
        }
    }

    public UserProfileResponse restoreDefaultProfileImage(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.getAuthProvider() == AuthProvider.local) {
            user.setProfileImageFilename(null);
        } else {
            user.setProfileImageFilename(user.getDefaultProfileImageFilename());
        }

        userRepository.save(user);

        return new UserProfileResponse(
                user.getEmail(),
                user.getUsername(),
                s3StorageService.generatePresignedUrl(user.getProfileImageFilename())
                        .orElse(null),
                user.getAuthProvider()
        );
    }

    public void changePassword(Long userId, String currentPassword, String newPassword) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Current password is incorrect");
        }

        if (newPassword.length() < 8) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Password must be at least 8 characters");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    public void changeUsername(Long userId, String newUsername) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (newUsername.length() < 3) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Username must be at least 3 characters");
        }

        user.setUsername(newUsername);
        userRepository.save(user);
    }
}