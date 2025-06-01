package com.ai.triptailor.response;

public class NotificationResponse {
    private int status;
    private String message;

    public NotificationResponse() {
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
