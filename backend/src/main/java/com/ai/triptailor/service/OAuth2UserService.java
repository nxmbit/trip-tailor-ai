package com.ai.triptailor.service;

import com.ai.triptailor.exception.OAuth2InAuthenticationProcessingException;
import com.ai.triptailor.model.AuthProvider;
import com.ai.triptailor.model.User;
import com.ai.triptailor.model.UserPrincipal;
import com.ai.triptailor.oauth2.OAuth2UserInfo;
import com.ai.triptailor.oauth2.OAuth2UserInfoFactory;
import com.ai.triptailor.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.Optional;

@Service
public class OAuth2UserService extends DefaultOAuth2UserService {
    private final UserRepository userRepository;

    @Autowired
    public OAuth2UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
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

        user.setAuthProvider(AuthProvider.valueOf(userRequest.getClientRegistration().getRegistrationId().toLowerCase()));
        user.setProvidersId(userRequest.getClientRegistration().getRegistrationId());
        user.setUsername(userInfo.getName());
        user.setEmail(userInfo.getEmail());
        user.setProfileImageUrl(userInfo.getImageUrl());
        user.setEnabled(true);
        return userRepository.save(user);
    }

    private User updateUser(User user, OAuth2UserInfo userInfo) {
        user.setUsername(userInfo.getName());
        user.setProfileImageUrl(userInfo.getImageUrl());
        return userRepository.save(user);
    }
}
