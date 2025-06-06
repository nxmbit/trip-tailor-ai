package com.ai.triptailor.controller;

import com.ai.triptailor.model.UserPrincipal;
import com.ai.triptailor.request.PasswordChangeRequest;
import com.ai.triptailor.request.UsernameChangeRequest;
import com.ai.triptailor.response.UserProfileResponse;
import com.ai.triptailor.service.UserProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/users")
public class UserProfileController {

    private final UserProfileService userProfileService;

    @Autowired
    public UserProfileController(UserProfileService userProfileService) {
        this.userProfileService = userProfileService;
    }

    @GetMapping("/profile")
    public ResponseEntity<UserProfileResponse> getUserProfile(@AuthenticationPrincipal UserPrincipal currentUser) {
        UserProfileResponse profile = userProfileService.getUserProfile(currentUser.getId());
        return ResponseEntity.ok(profile);
    }

    @PostMapping("/profile/image")
    public ResponseEntity<UserProfileResponse> updateProfileImage(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @RequestParam MultipartFile profileImage) {
        UserProfileResponse updatedProfile = userProfileService.updateProfileImage(currentUser.getId(), profileImage);
        return ResponseEntity.ok(updatedProfile);
    }

    @PostMapping("/profile/image-reset")
    public ResponseEntity<UserProfileResponse> resetProfileImage(
            @AuthenticationPrincipal UserPrincipal currentUser) {
        UserProfileResponse updatedProfile = userProfileService.restoreDefaultProfileImage(currentUser.getId());
        return ResponseEntity.ok(updatedProfile);
    }

    @PostMapping("/profile/password")
    public ResponseEntity<Void> changePassword(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @RequestBody PasswordChangeRequest passwordChangeRequest) {
        userProfileService.changePassword(currentUser.getId(),
                passwordChangeRequest.getCurrentPassword(),
                passwordChangeRequest.getNewPassword());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/profile/username")
    public ResponseEntity<Void> changeUsername(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @RequestBody UsernameChangeRequest usernameChangeRequest) {
        userProfileService.changeUsername(currentUser.getId(), usernameChangeRequest.getUsername());
        return ResponseEntity.ok().build();
    }
}