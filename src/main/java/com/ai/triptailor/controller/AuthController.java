package com.ai.triptailor.controller;

import com.ai.triptailor.dto.LoginRequestDto;
import com.ai.triptailor.dto.RefreshTokenRequestDto;
import com.ai.triptailor.dto.RegisterRequestDto;
import com.ai.triptailor.model.User;
import com.ai.triptailor.model.UserPrincipal;
import com.ai.triptailor.response.LoginResponse;
import com.ai.triptailor.service.AuthService;
import com.ai.triptailor.service.JwtService;
import com.ai.triptailor.service.RefreshTokenService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;


@RestController
@RequestMapping("/auth")
public class AuthController {
    private final JwtService jwtService;
    private final AuthService authService;
    private final RefreshTokenService refreshTokenService;

    @Autowired
    public AuthController(JwtService jwtService, AuthService authService, RefreshTokenService refreshTokenService) {
        this.jwtService = jwtService;
        this.authService = authService;
        this.refreshTokenService = refreshTokenService;
    }

    @PostMapping("/register")
    public ResponseEntity<User> register(@Valid @RequestBody RegisterRequestDto userData) {
        User user = authService.register(userData);
        return ResponseEntity.ok(user);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequestDto userData) {
        LoginResponse loginResponse = authService.authenticate(userData);
        return ResponseEntity.ok(loginResponse);
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<LoginResponse> refreshToken(@Valid @RequestBody RefreshTokenRequestDto refreshTokenRequest) {
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
}
