package com.ai.triptailor.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.hypersistence.utils.hibernate.type.json.JsonType;
import jakarta.persistence.*;
import org.hibernate.annotations.Type;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

@Entity
@Table(name = "travel_plan_day")
public class TravelPlanDay {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private LocalDateTime date;
    private int dayNumber;

    @Type(JsonType.class)
    @Column(columnDefinition = "jsonb")
    private Map<String, String> description = new HashMap<>();

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "travel_plan_id", nullable = false)
    private TravelPlan travelPlan;

    @OneToMany(mappedBy = "travelPlanDay", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<Attraction> attractions;

    public void addAttraction(Attraction attraction) {
        if (this.attractions == null) {
            this.attractions = new HashSet<>();
        }
        this.attractions.add(attraction);
        attraction.setTravelPlanDay(this);
    }

    public void removeAttraction(Attraction attraction) {
        if (this.attractions != null) {
            this.attractions.remove(attraction);
            attraction.setTravelPlanDay(null);
        }
    }

    public TravelPlanDay() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public LocalDateTime getDate() {
        return date;
    }

    public void setDate(LocalDateTime date) {
        this.date = date;
    }

    public int getDayNumber() {
        return dayNumber;
    }

    public void setDayNumber(int dayNumber) {
        this.dayNumber = dayNumber;
    }

    public TravelPlan getTravelPlan() {
        return travelPlan;
    }

    public void setTravelPlan(TravelPlan travelPlan) {
        this.travelPlan = travelPlan;
    }

    public Set<Attraction> getAttractions() {
        return attractions;
    }

    public void setAttractions(Set<Attraction> attractions) {
        this.attractions = attractions;
    }

    public Map<String, String> getDescription() {
        return description;
    }

    public void setDescription(Map<String, String> description) {
        this.description = description;
    }

    public void addDescription(String languageCode, String text) {
        this.description.put(languageCode, text);
    }

    public String getDescription(String languageCode) {
        return this.description.getOrDefault(languageCode, this.description.getOrDefault("en", ""));
    }
}
