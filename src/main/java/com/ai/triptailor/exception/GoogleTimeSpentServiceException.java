package com.ai.triptailor.exception;

public class GoogleTimeSpentServiceException extends RuntimeException {
    public GoogleTimeSpentServiceException(String message) {
        super(message);
    }

    public GoogleTimeSpentServiceException(String message, Throwable cause) {
        super(message, cause);
    }
}
