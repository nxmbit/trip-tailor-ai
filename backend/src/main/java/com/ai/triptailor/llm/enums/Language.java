package com.ai.triptailor.llm.enums;

import java.util.Arrays;
import java.util.Optional;

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

    public static Optional<Language> fromCodeOptional(String code) {
        if (code == null) {
            return Optional.empty();
        }

        return Arrays.stream(Language.values())
                .filter(language -> language.getCode().equalsIgnoreCase(code))
                .findFirst();
    }
}
