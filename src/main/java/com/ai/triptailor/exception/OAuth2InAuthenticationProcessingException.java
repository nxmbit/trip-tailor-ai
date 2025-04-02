package com.ai.triptailor.exception;

import org.springframework.security.core.AuthenticationException;

public class OAuth2InAuthenticationProcessingException extends AuthenticationException {
    public OAuth2InAuthenticationProcessingException(String msg, Throwable t) {
        super(msg, t);
    }

    public OAuth2InAuthenticationProcessingException(String msg) {
        super(msg);
    }
}
