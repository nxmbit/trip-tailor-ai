package com.ai.triptailor.controller;

import com.ai.triptailor.model.UserPrincipal;
import com.ai.triptailor.response.UserProfileResponse;
import com.ai.triptailor.service.UserProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
}