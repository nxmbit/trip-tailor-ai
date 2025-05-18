package com.ai.triptailor.service;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.exception.SdkException;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest;
import software.amazon.awssdk.services.s3.presigner.model.PresignedGetObjectRequest;

import java.io.IOException;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.Optional;

@Service
public class S3StorageService {
    @Value("${aws.s3.bucket-name}")
    private String bucketName;

    @Value("${aws.s3.link-expiration}")
    private long linkExpiration;

    private final S3Client s3Client;
    private final S3Presigner presigner;

    private static final Logger logger = LoggerFactory.getLogger(S3StorageService.class);

    @Autowired
    public S3StorageService(S3Client s3Client, S3Presigner s3Presigner) {
        this.s3Client = s3Client;
        this.presigner = s3Presigner;
    }

    /**
     * Upload file to S3 using its SHA-256 hash as the key
     * Returns Optional.empty() on failure rather than throwing exceptions
     *
     * @param fileData Binary content to upload
     * @param contentType MIME type of the content
     * @param extension File extension (e.g., "jpg", "png")
     * @return Optional containing the S3 key if successful, empty if failed
     */
    public Optional<String> uploadFile(byte[] fileData, String contentType, String extension) {
        try {
            String hash = calculateSHA256(fileData);
            String key = hash + "." + extension;

            // Check if the file already exists
            if (fileExists(key)) {
                logger.info("File with hash {} already exists in S3, skipping upload", hash);
                return Optional.of(key);
            }

            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .contentType(contentType)
                    .build();

            s3Client.putObject(putObjectRequest, RequestBody.fromBytes(fileData));
            logger.info("Successfully uploaded file to S3 with key: {}", key);
            return Optional.of(key);
        } catch (Exception e) {
            logger.error("Error uploading file to S3: {}", e.getMessage(), e);
            return Optional.empty();
        }
    }

    /**
     * Calculate SHA-256 hash for the given data
     *
     * @param data The data to hash
     * @return The hex representation of the hash
     */
    private String calculateSHA256(byte[] data) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(data);
            return HexFormat.of().formatHex(hash);
        } catch (Exception e) {
            throw new RuntimeException("Error calculating SHA-256 hash", e);
        }
    }

    /**
     * Download file from S3
     *
     * @param key S3 object key (hash.extension)
     * @return File content as byte array if found
     */
    public Optional<byte[]> downloadFile(String key) {
        try {
            GetObjectRequest getObjectRequest = GetObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build();

            ResponseInputStream<GetObjectResponse> response = s3Client.getObject(getObjectRequest);
            byte[] content = response.readAllBytes();
            logger.info("Successfully downloaded file from S3: {}", key);
            return Optional.of(content);
        } catch (NoSuchKeyException e) {
            logger.warn("File not found in S3: {}", key);
            return Optional.empty();
        } catch (IOException | SdkException e) {
            logger.error("Error downloading file from S3: {}", e.getMessage(), e);
            return Optional.empty();
        }
    }

    /**
     * Checks if a file with the given key exists in S3
     *
     * @param key S3 object key
     * @return true if the file exists, false otherwise
     */
    public boolean fileExists(String key) {
        try {
            HeadObjectRequest headObjectRequest = HeadObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build();

            s3Client.headObject(headObjectRequest);
            return true;
        } catch (NoSuchKeyException e) {
            return false;
        } catch (SdkException e) {
            logger.error("Error checking if file exists in S3: {}", e.getMessage(), e);
            return false;
        }
    }

    /**
     * Deletes a file from S3
     *
     * @param key S3 object key
     * @return true if deletion was successful, false otherwise
     */
    public boolean deleteFile(String key) {
        try {
            DeleteObjectRequest deleteObjectRequest = DeleteObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build();

            s3Client.deleteObject(deleteObjectRequest);
            logger.info("Successfully deleted file from S3: {}", key);
            return true;
        } catch (SdkException e) {
            logger.error("Error deleting file from S3: {}", e.getMessage(), e);
            return false;
        }
    }

    /**
     * Generates a pre-signed URL for temporary access to a file
     *
     * @param key S3 object key
     * @param expirationSeconds URL expiration time in seconds
     * @return Optional containing the pre-signed URL if successful
     */
    public Optional<String> generatePresignedUrl(String key, long expirationSeconds) {
        try {
            if (StringUtils.isEmpty(key)) {
                return Optional.empty();
            }

            GetObjectRequest getObjectRequest = GetObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build();

            GetObjectPresignRequest presignRequest = GetObjectPresignRequest.builder()
                            .signatureDuration(java.time.Duration.ofSeconds(expirationSeconds))
                            .getObjectRequest(getObjectRequest)
                            .build();

            PresignedGetObjectRequest presignedRequest =
                    presigner.presignGetObject(presignRequest);

            String url = presignedRequest.url().toString();
            presigner.close();
            return Optional.of(url);
        } catch (Exception e) {
            logger.error("Error generating presigned URL: {}", e.getMessage(), e);
            return Optional.empty();
        }
    }

    /**
     * Generates a pre-signed URL for temporary access to a file with default expiration
     *
     * @param key S3 object key
     * @return Optional containing the pre-signed URL if successful
     */
    public Optional<String> generatePresignedUrl(String key) {
        return generatePresignedUrl(key, linkExpiration);
    }
}
