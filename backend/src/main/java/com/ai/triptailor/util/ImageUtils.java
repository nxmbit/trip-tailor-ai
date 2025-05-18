package com.ai.triptailor.util;

import java.util.Optional;

public class ImageUtils {
    public static Optional<String> getExtensionFromContentType(String contentType) {
        return switch (contentType.toLowerCase()) {
            case "image/jpeg", "image/jpg" -> Optional.of("jpg");
            case "image/png" -> Optional.of("png");
            case "image/gif" -> Optional.of("gif");
            case "image/webp" -> Optional.of("webp");
            default -> Optional.empty();
        };
    }
}