package com.ai.triptailor.repository;

import com.ai.triptailor.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByusername(String username);
    Optional<User> findByemail(String email);
    Boolean existsByusername(String username);
    Boolean existsByemail(String email);
    List<User> findByTravelPlansIsEmpty();

    // Find users whose most recent travel plan is before the cutoff date
    @Query("SELECT u FROM User u WHERE u.id IN (" +
            "  SELECT tp.user.id FROM TravelPlan tp " +
            "  GROUP BY tp.user.id " +
            "  HAVING MAX(tp.createdAt) < :cutoffDate" +
            ")")
    List<User> findUsersWithLastPlanBefore(Instant cutoffDate);
}
