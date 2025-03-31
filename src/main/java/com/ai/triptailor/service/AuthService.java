package com.ai.triptailor.service;

import com.ai.triptailor.dto.LoginRequestDto;
import com.ai.triptailor.dto.RegisterRequestDto;
import com.ai.triptailor.model.User;
import com.ai.triptailor.model.UserPrincipal;
import com.ai.triptailor.repository.UserRepository;
import com.ai.triptailor.responses.LoginResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {
    private UserRepository userRepository;
    private PasswordEncoder passwordEncoder;
    private JwtService jwtService;
    private AuthenticationManager authenticationManager;

    @Autowired
    public AuthService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            AuthenticationManager authenticationManager
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
    }

    public User register(RegisterRequestDto userData) {
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

    public LoginResponse authenticate(LoginRequestDto userData) {
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

        return new LoginResponse(
                jwtToken,
                user.getEmail(),
                jwtService.getExpirationDate(jwtToken)
        );
    }
}
