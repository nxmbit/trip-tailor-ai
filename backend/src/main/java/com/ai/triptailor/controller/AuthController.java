package com.ai.triptailor.controller;

import com.ai.triptailor.request.FcmTokenRequest;
import com.ai.triptailor.request.LoginRequest;
import com.ai.triptailor.request.RefreshTokenRequest;
import com.ai.triptailor.request.RegisterRequest;
import com.ai.triptailor.model.User;
import com.ai.triptailor.model.UserPrincipal;
import com.ai.triptailor.response.LoginResponse;
import com.ai.triptailor.service.AuthService;
import com.ai.triptailor.service.FcmTokenService;
import com.ai.triptailor.service.JwtService;
import com.ai.triptailor.service.RefreshTokenService;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;


@RestController
@RequestMapping("/auth")
public class AuthController {
    private final JwtService jwtService;
    private final AuthService authService;
    private final RefreshTokenService refreshTokenService;
    private final FcmTokenService fcmTokenService;

    @Autowired
    public AuthController(JwtService jwtService, AuthService authService,
                          RefreshTokenService refreshTokenService, FcmTokenService fcmTokenService) {
        this.jwtService = jwtService;
        this.authService = authService;
        this.refreshTokenService = refreshTokenService;
        this.fcmTokenService = fcmTokenService;
    }

    @PostMapping("/register")
    public ResponseEntity<User> register(@Valid @RequestBody RegisterRequest userData) {
        User user = authService.register(userData);
        return ResponseEntity.ok(user);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest userData) {
        LoginResponse loginResponse = authService.authenticate(userData);
        return ResponseEntity.ok(loginResponse);
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<LoginResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest refreshTokenRequest) {
        LoginResponse refreshTokenResponse = authService.refreshToken(refreshTokenRequest);
        return ResponseEntity.ok(refreshTokenResponse);
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout() {
        UserPrincipal userPrincipal = (UserPrincipal) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        Long userId = userPrincipal.getId();
        refreshTokenService.deleteByUserId(userId);
        return ResponseEntity.ok().body(Map.of("message", "Logout successful"));
    }

    @GetMapping("/tokens")
    public ResponseEntity<?> getTokens(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        String refreshToken = null;

        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("refresh_token".equals(cookie.getName())) {
                    refreshToken = cookie.getValue();
                }
            }
        }

        if (refreshToken != null) {
            LoginResponse response = authService.validateTokensFromCookies(refreshToken);
            if (response != null) {
                return ResponseEntity.ok(response);
            }
        }

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }

    @PostMapping("/fcm-token")
    public ResponseEntity<?> saveFcmToken(@RequestBody FcmTokenRequest request) {
        UserPrincipal userPrincipal = (UserPrincipal) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        Long userId = userPrincipal.getId();

        try {
            fcmTokenService.saveToken(request.getToken(), userId);
            return ResponseEntity.ok(Map.of("message", "FCM token saved successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to save FCM token: " + e.getMessage()));
        }
    }

    @DeleteMapping("/fcm-token")
    public ResponseEntity<?> deleteFcmToken(@RequestBody FcmTokenRequest request) {
        UserPrincipal userPrincipal = (UserPrincipal) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        Long userId = userPrincipal.getId();

        try {
            fcmTokenService.deleteTokenForUser(request.getToken(), userId);
            return ResponseEntity.ok(Map.of("message", "FCM token deleted successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to delete FCM token: " + e.getMessage()));
        }
    }
}
