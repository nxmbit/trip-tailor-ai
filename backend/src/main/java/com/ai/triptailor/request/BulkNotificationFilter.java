package com.ai.triptailor.request;

public enum BulkNotificationFilter {
    ALL_USERS("allUsers"),
    LAST_PLAN_OLDER_THAN("lastPlanOlderThan"),
    NO_PLANS("noPlans");

    private final String code;

    BulkNotificationFilter(String code) {
        this.code = code;
    }

    public String getCode() {
        return code;
    }

    public static BulkNotificationFilter fromCode(String code) {
        if (code == null) return ALL_USERS;

        for (BulkNotificationFilter filter : values()) {
            if (filter.code.equals(code)) {
                return filter;
            }
        }
        return ALL_USERS;
    }
}