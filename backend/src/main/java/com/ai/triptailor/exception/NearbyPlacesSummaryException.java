package com.ai.triptailor.exception;

public class NearbyPlacesSummaryException extends RuntimeException {
    public NearbyPlacesSummaryException(String message) {
        super(message);
    }
    public NearbyPlacesSummaryException(String message, Throwable cause) {
        super(message, cause);
    }
}
