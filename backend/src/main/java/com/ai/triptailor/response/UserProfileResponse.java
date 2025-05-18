package com.ai.triptailor.response;

import com.ai.triptailor.model.AuthProvider;

public class UserProfileResponse {
    private String email;
    private String username;
    private String photoUrl;
    private AuthProvider authProvider;

    public UserProfileResponse(String email, String username, String photoUrl, AuthProvider authProvider) {
        this.email = email;
        this.username = username;
        this.photoUrl = photoUrl;
        this.authProvider = authProvider;
    }

    public UserProfileResponse() {
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public AuthProvider getAuthProvider() {
        return authProvider;
    }

    public void setAuthProvider(AuthProvider authProvider) {
        this.authProvider = authProvider;
    }
}

