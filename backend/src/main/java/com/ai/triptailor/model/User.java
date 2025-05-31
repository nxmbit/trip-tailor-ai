package com.ai.triptailor.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

import javax.validation.constraints.NotNull;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "app_user")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String username;

    @Column(unique = true, nullable = false)
    private String email;

    @JsonIgnore
    private String password;

    @Column(name = "enabled", nullable = false)
    private Boolean enabled;

    @NotNull
    @Enumerated(EnumType.STRING)
    private AuthProvider authProvider;

    private String profileImageFilename;

    private String defaultProfileImageFilename;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
    private Set<TravelPlan> travelPlans;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
    private List<FcmToken> fcmTokens;

    private Long generationsNumber;

    public User(String username, String email, String password) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.enabled = false; // Default to disabled
        this.authProvider = AuthProvider.local; // Default to local authentication
        this.profileImageFilename = null;
        this.defaultProfileImageFilename = null;
    }

    public User() {}

    public void addTravelPlan(TravelPlan travelPlan) {
        if (this.travelPlans == null) {
            this.travelPlans = new HashSet<>();
        }
        this.travelPlans.add(travelPlan);
        travelPlan.setUser(this);
    }

    public void removeTravelPlan(TravelPlan travelPlan) {
        if (this.travelPlans != null) {
            this.travelPlans.remove(travelPlan);
            travelPlan.setUser(null);
        }
    }

    public Set<TravelPlan> getTravelPlans() {
        return travelPlans;
    }

    public void setTravelPlans(Set<TravelPlan> travelPlans) {
        this.travelPlans = travelPlans;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public AuthProvider getAuthProvider() {
        return authProvider;
    }

    public void setAuthProvider(AuthProvider authProvider) {
        this.authProvider = authProvider;
    }

    public String getProfileImageFilename() {
        return profileImageFilename;
    }

    public void setProfileImageFilename(String profileImageUrl) {
        this.profileImageFilename = profileImageUrl;
    }

    public Boolean getEnabled() {
        return enabled;
    }

    public void setEnabled(Boolean enabled) {
        this.enabled = enabled;
    }

    public Long getGenerationsNumber() {
        return generationsNumber;
    }

    public void setGenerationsNumber(Long generationsNumber) {
        this.generationsNumber = generationsNumber;
    }

    public String getDefaultProfileImageFilename() {
        return defaultProfileImageFilename;
    }

    public void setDefaultProfileImageFilename(String defaultProfileImageFilename) {
        this.defaultProfileImageFilename = defaultProfileImageFilename;
    }

    public List<FcmToken> getFcmTokens() {
        return fcmTokens;
    }

    public void setFcmTokens(List<FcmToken> fcmTokens) {
        this.fcmTokens = fcmTokens;
    }

    public void addFcmToken(FcmToken fcmToken) {
        if (this.fcmTokens == null) {
            this.fcmTokens = new java.util.ArrayList<>();
        }
        this.fcmTokens.add(fcmToken);
        fcmToken.setUser(this);
    }

    public void removeFcmToken(FcmToken fcmToken) {
        if (this.fcmTokens != null) {
            this.fcmTokens.remove(fcmToken);
            fcmToken.setUser(null);
        }
    }
}
