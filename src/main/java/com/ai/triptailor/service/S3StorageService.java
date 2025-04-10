package com.ai.triptailor.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.s3.S3Client;

import java.security.MessageDigest;
import java.util.HexFormat;

@Service
public class S3StorageService {
    @Value("${aws.s3.bucket-name}")
    private String bucketName;

    private final S3Client s3Client;

    @Autowired
    public S3StorageService(S3Client s3Client) {
        this.s3Client = s3Client;
    }

    private String calculateSHA256(byte[] data) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(data);
            return HexFormat.of().formatHex(hash);
        } catch (Exception e) {
            throw new RuntimeException("Error calculating SHA-256 hash", e);
        }
    }
}
