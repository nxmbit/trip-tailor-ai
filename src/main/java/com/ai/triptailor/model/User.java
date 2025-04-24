package com.ai.triptailor.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

import javax.validation.constraints.NotNull;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "app_user")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "username", nullable = false)
    private String username;

    @Column(name = "email", unique = true, nullable = false)
    private String email;

    @Column(name = "password")
    @JsonIgnore
    private String password;

    @Column(name = "enabled", nullable = false)
    private Boolean enabled;

    @Column(name = "auth_provider")
    @NotNull
    @Enumerated(EnumType.STRING)
    private AuthProvider authProvider;

    @Column(name = "profile_image_url")
    private String profileImageUrl;

    // This field is used for OAuth2 providers like Google, Facebook, etc.
    // It stores the unique identifier provided by the OAuth2 provider.
    @Column(name = "providers_id")
    private String providersId;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
    private Set<Trip> trips;

    public User(String username, String email, String password) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.enabled = false; // Default to disabled
        this.authProvider = AuthProvider.local; // Default to local authentication
        this.profileImageUrl = null;
        this.providersId = null;
    }

    public User() {}

    public void addTrip(Trip trip) {
        if (this.trips == null) {
            this.trips = new HashSet<>();
        }
        this.trips.add(trip);
        trip.setUser(this);
    }

    public void removeTrip(Trip trip) {
        if (this.trips != null) {
            this.trips.remove(trip);
            trip.setUser(null);
        }
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

    public String getProfileImageUrl() {
        return profileImageUrl;
    }

    public void setProfileImageUrl(String profileImageUrl) {
        this.profileImageUrl = profileImageUrl;
    }

    public String getProvidersId() {
        return providersId;
    }

    public void setProvidersId(String providersId) {
        this.providersId = providersId;
    }

    public Boolean getEnabled() {
        return enabled;
    }

    public void setEnabled(Boolean enabled) {
        this.enabled = enabled;
    }


}
