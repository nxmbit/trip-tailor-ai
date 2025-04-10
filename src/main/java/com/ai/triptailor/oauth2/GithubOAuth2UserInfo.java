package com.ai.triptailor.oauth2;

import org.springframework.util.StringUtils;

import java.util.Map;

public class GithubOAuth2UserInfo extends OAuth2UserInfo {

    public GithubOAuth2UserInfo(Map<String, Object> attributes) {
        super(attributes);
    }

    @Override
    public String getId() {
        return ((Integer) attributes.get("id")).toString();
    }

    @Override
    public String getName() {
        return (String) attributes.get("login");
    }

    @Override
    public String getEmail() {
        // Get email, or use GitHub username as fallback
        String email = (String) attributes.get("email");
        if (!StringUtils.hasText(email)) {
            String login = (String) attributes.get("login");
            return login + "@github.triptailor.user"; // Create a placeholder email
        }
        return email;
    }

    @Override
    public String getImageUrl() {
        return (String) attributes.get("avatar_url");
    }
}