package com.ai.triptailor.responses;

public class LoginResponse {
    private String token;
    private String email;
    private long expirationDate;

    public LoginResponse(String token, String email, long expirationDate) {
        this.token = token;
        this.email = email;
        this.expirationDate = expirationDate;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public long getExpirationDate() {
        return expirationDate;
    }

    public void setExpirationDate(long expirationDate) {
        this.expirationDate = expirationDate;
    }
}
