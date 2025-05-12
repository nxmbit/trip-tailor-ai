package com.ai.triptailor.response;

public class LoginResponse {
    private String jwtToken;
    private String refreshToken;
    private String email;
    private long jwtExpirationDate;
    private long refreshTokenExpirationDate;

    public LoginResponse(String jwtToken, String refreshToken, String email, long jwtExpirationDate,
                         long refreshTokenExpirationDate) {
        this.jwtToken = jwtToken;
        this.refreshToken = refreshToken;
        this.email = email;
        this.jwtExpirationDate = jwtExpirationDate;
        this.refreshTokenExpirationDate = refreshTokenExpirationDate;
    }

    public String getJwtToken() {
        return jwtToken;
    }

    public void setJwtToken(String jwtToken) {
        this.jwtToken = jwtToken;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public long getJwtExpirationDate() {
        return jwtExpirationDate;
    }

    public void setJwtExpirationDate(long jwtExpirationDate) {
        this.jwtExpirationDate = jwtExpirationDate;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public long getRefreshTokenExpirationDate() {
        return refreshTokenExpirationDate;
    }

    public void setRefreshTokenExpirationDate(long refreshTokenExpirationDate) {
        this.refreshTokenExpirationDate = refreshTokenExpirationDate;
    }
}
