package com.ai.triptailor.llm.enums;

public enum Language {
    ENGLISH("en", "English"),
    POLISH("pl", "Polish"),
    GERMAN("de", "German");

    private final String code;
    private final String name;

    Language(String code, String name) {
        this.code = code;
        this.name = name;
    }

    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }
}
