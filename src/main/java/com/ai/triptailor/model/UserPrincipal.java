package com.ai.triptailor.model;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.user.OAuth2User;

import java.util.Collection;
import java.util.Collections;
import java.util.Map;

public class UserPrincipal implements UserDetails, OAuth2User {
    private User user;
    Map<String, Object> oAuth2attributes;

    public UserPrincipal(User user) {
        this.user = user;
    }

    public UserPrincipal(User user, Map<String, Object> oAuth2attributes) {
        this.user = user;
        this.oAuth2attributes = oAuth2attributes;
    }

    @Override
    public Map<String, Object> getAttributes() {
        return oAuth2attributes;
    }

    public void setAttributes(Map<String, Object> oAuth2attributes) {
        this.oAuth2attributes = oAuth2attributes;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.singleton(new SimpleGrantedAuthority("ROLE_USER"));
    }

    @Override
    public String getPassword() {
        return user.getPassword();
    }

    /**
     * In this application, we use email as the username for Spring Security authentication.
     * This is why getUsername() returns the user's email.
     *
     * @return the user's email address which serves as the username for authentication
     */
    @Override
    public String getUsername() {
        return user.getEmail();
    }

    //  TODO: Implement later
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return user.getEnabled();
    }

    @Override
    public String getName() {
        return String.valueOf(user.getId());
    }
}
