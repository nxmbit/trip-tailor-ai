package com.ai.triptailor.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;

@Configuration
public class AwsConfiguration {
    @Value("${aws.s3.access-key}")
    private String awsAccessKey;

    @Value("${aws.s3.secret-key}")
    private String awsSecretKey;

    @Value("${aws.s3.region}")
    private String awsRegion;

    @Bean
    public S3Client s3Client() {
        AwsCredentials credentials = AwsBasicCredentials.create(awsAccessKey, awsSecretKey);
        return S3Client.builder()
                .credentialsProvider(StaticCredentialsProvider.create(credentials))
                .region(Region.of(awsRegion))
                .build();

    }
}
