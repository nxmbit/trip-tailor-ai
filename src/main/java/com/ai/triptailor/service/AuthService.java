package com.ai.triptailor.service;

import com.ai.triptailor.request.LoginRequest;
import com.ai.triptailor.request.RefreshTokenRequest;
import com.ai.triptailor.request.RegisterRequest;
import com.ai.triptailor.exception.RefreshTokenException;
import com.ai.triptailor.model.RefreshToken;
import com.ai.triptailor.model.User;
import com.ai.triptailor.model.UserPrincipal;
import com.ai.triptailor.repository.UserRepository;
import com.ai.triptailor.response.LoginResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final RefreshTokenService refreshTokenService;

    @Autowired
    public AuthService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            AuthenticationManager authenticationManager,
            RefreshTokenService refreshTokenService
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.refreshTokenService = refreshTokenService;
    }

    public User register(RegisterRequest userData) {
        User user = new User(
                userData.getUsername(),
                userData.getEmail(),
                userData.getPassword()
        );
        if (userRepository.existsByemail(user.getEmail())) {
            throw new RuntimeException("Provided email is already in use.");
        }

        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setEnabled(true);
        return userRepository.save(user);
    }

    public LoginResponse authenticate(LoginRequest userData) {
        User user = userRepository.findByemail(userData.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found with email: " + userData.getEmail()));

        if (!user.getEnabled()) {
            throw new RuntimeException("Account is not verified. Verify your account to login.");
        }

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        user.getEmail(),
                        userData.getPassword()
                )
        );

        String jwtToken = jwtService.createToken(new UserPrincipal(user));
        refreshTokenService.deleteByUserId(user.getId());
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(user.getId());

        return new LoginResponse(
                jwtToken,
                refreshToken.getToken(),
                user.getEmail(),
                jwtService.getExpirationDate(jwtToken),
                refreshToken.getExpiryDate().toEpochMilli()
        );
    }

    public LoginResponse refreshToken(RefreshTokenRequest refreshTokenRequest) {
        String refreshToken = refreshTokenRequest.getRefreshToken();

        return refreshTokenService.findByRefreshToken(refreshToken)
                .map(refreshTokenService::verifyExpiration)
                .map(RefreshToken::getUser)
                .map(user -> {
                    String jwtToken = jwtService.createToken(new UserPrincipal(user));
                    refreshTokenService.deleteByUserId(user.getId());
                    RefreshToken newRefreshToken = refreshTokenService.createRefreshToken(user.getId()); //refresh token rotation

                    return new LoginResponse(
                            jwtToken,
                            newRefreshToken.getToken(),
                            user.getEmail(),
                            jwtService.getExpirationDate(jwtToken),
                            newRefreshToken.getExpiryDate().toEpochMilli()
                    );
                })
                .orElseThrow(() -> new RefreshTokenException("Refresh token is not in database!"));
    }

    public LoginResponse validateTokensFromCookies(String refreshToken) {
        return refreshTokenService.findByRefreshToken(refreshToken)
                .map(refreshTokenService::verifyExpiration)
                .map(token -> {
                    User user = token.getUser();
                    // Create new tokens
                    String newJwtToken = jwtService.createToken(new UserPrincipal(user));
                    refreshTokenService.deleteByUserId(user.getId());
                    RefreshToken newRefreshToken = refreshTokenService.createRefreshToken(user.getId());

                    return new LoginResponse(
                            newJwtToken,
                            newRefreshToken.getToken(),
                            user.getEmail(),
                            jwtService.getExpirationDate(newJwtToken),
                            newRefreshToken.getExpiryDate().toEpochMilli()
                    );
                })
                .orElse(null);
    }
}
