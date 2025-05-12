package com.ai.triptailor.exception;

public class GoogleMapsServiceException extends RuntimeException {
    public GoogleMapsServiceException(String message) {
        super(message);
    }

    public GoogleMapsServiceException(String message, Throwable cause) {
        super(message, cause);
    }
}