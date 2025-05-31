package com.ai.triptailor.repository;

import com.ai.triptailor.model.FcmToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FcmTokenRepository extends JpaRepository<FcmToken, Long> {
    Optional<FcmToken> findByToken(String token);
    Optional<FcmToken> findByTokenAndUserId(String token, Long userId);
    List<FcmToken> findByUserId(Long userId);
    void deleteByToken(String token);
    void deleteByTokenAndUserId(String token, Long userId);
}
