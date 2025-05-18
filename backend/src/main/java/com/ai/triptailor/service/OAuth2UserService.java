package com.ai.triptailor.service;

import com.ai.triptailor.exception.OAuth2InAuthenticationProcessingException;
import com.ai.triptailor.model.AuthProvider;
import com.ai.triptailor.model.User;
import com.ai.triptailor.model.UserPrincipal;
import com.ai.triptailor.oauth2.OAuth2UserInfo;
import com.ai.triptailor.oauth2.OAuth2UserInfoFactory;
import com.ai.triptailor.repository.UserRepository;
import com.ai.triptailor.util.ImageUtils;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.io.InputStream;
import java.net.*;
import java.util.Optional;

@Service
public class OAuth2UserService extends DefaultOAuth2UserService {
    private final UserRepository userRepository;
    private final S3StorageService s3StorageService;

    public OAuth2UserService(UserRepository userRepository, S3StorageService s3StorageService) {
        this.userRepository = userRepository;
        this.s3StorageService = s3StorageService;
    }

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);

        try {
            OAuth2UserInfo oAuth2UserInfo = OAuth2UserInfoFactory.createOAuth2UserInfo(
                    userRequest.getClientRegistration().getRegistrationId(),
                    oAuth2User.getAttributes()
            );

            String userEmail = oAuth2UserInfo.getEmail();
            if (!StringUtils.hasText(userEmail)) {
                throw new OAuth2InAuthenticationProcessingException(
                        "Could not get email from OAuth2 provider: " + userRequest.getClientRegistration().getRegistrationId());
            }

            Optional<User> userOptional = userRepository.findByemail(userEmail);
            User user;

            if (userOptional.isPresent()) {
                user = userOptional.get();

                // Check if the user with the same email is already registered with a different provider
                if (!user.getAuthProvider().equals(AuthProvider.valueOf(userRequest.getClientRegistration().getRegistrationId()))) {
                    throw new OAuth2InAuthenticationProcessingException(
                            "You are already registered using " + user.getAuthProvider() + " account. Please use "
                                    + user.getAuthProvider() + "account to login."
                    );
                }
                // Update user information on login
                user = updateUser(user, oAuth2UserInfo);
            } else {
                user = registerUser(userRequest, oAuth2UserInfo);
            }

            return new UserPrincipal(user, oAuth2User.getAttributes());

        } catch (AuthenticationException authEx) {
            // this will trigger the OAuth2AuthenticationFailureHandler
            throw authEx;
        } catch (Exception e) {
            throw new InternalAuthenticationServiceException(e.getMessage(), e);
        }
    }

    private User registerUser(OAuth2UserRequest userRequest, OAuth2UserInfo userInfo) {
        User user = new User();
        String s3ImageUrl = downloadAndStoreProfileImage(userInfo.getImageUrl()).orElse(null);

        user.setAuthProvider(AuthProvider.valueOf(userRequest.getClientRegistration().getRegistrationId().toLowerCase()));
        user.setUsername(userInfo.getName());
        user.setEmail(userInfo.getEmail());
        user.setProfileImageFilename(s3ImageUrl);
        user.setDefaultProfileImageFilename(s3ImageUrl);
        user.setEnabled(true);
        return userRepository.save(user);
    }

    private User updateUser(User user, OAuth2UserInfo userInfo) {
        String s3ImageUrl = downloadAndStoreProfileImage(userInfo.getImageUrl()).orElse(null);
        user.setUsername(userInfo.getName());
        user.setDefaultProfileImageFilename(s3ImageUrl);
        return userRepository.save(user);
    }

    private Optional<String> downloadAndStoreProfileImage(String imageUrl) {
        try {
            URL url = new URI(imageUrl).toURL();
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");

            String contentType = connection.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return Optional.empty();
            }

            String extension = ImageUtils.getExtensionFromContentType(contentType)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported image type"));


            try (InputStream inputStream = connection.getInputStream()) {
                return s3StorageService.uploadFile(inputStream.readAllBytes(), contentType, extension);
            }
        } catch (Exception e) {
            // Log error but continue without profile image
            return Optional.empty();
        }
    }
}
