package com.ai.triptailor.repository;

import com.ai.triptailor.model.TravelPlan;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface TravelPlanRepository extends JpaRepository<TravelPlan, UUID> {
    Page<TravelPlan> findByUserId(Long userId, Pageable pageable);
}