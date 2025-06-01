package com.ai.triptailor.request;

public enum BulkNotificationFilterParams {
    DAYS("days", "Number of days for filtering");

    private final String key;
    private final String description;

    BulkNotificationFilterParams(String key, String description) {
        this.key = key;
        this.description = description;
    }

    public String getKey() {
        return key;
    }

    public String getDescription() {
        return description;
    }
}