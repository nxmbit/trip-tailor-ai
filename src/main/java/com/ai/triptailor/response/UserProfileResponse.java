package com.ai.triptailor.response;

public class UserProfileResponse {
    private String email;
    private String username;
    private String photoUrl;

    public UserProfileResponse(String email, String username, String photoUrl) {
        this.email = email;
        this.username = username;
        this.photoUrl = photoUrl;
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

}

