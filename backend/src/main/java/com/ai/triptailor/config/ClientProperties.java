package com.ai.triptailor.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "client")
public class ClientProperties {
    private ClientType type = ClientType.WEB;

    public enum ClientType {
        WEB,
        MOBILE
    }

    public ClientType getType() {
        return type;
    }

    public void setType(ClientType type) {
        this.type = type;
    }
}
