package com.ai.triptailor.oauth2;

import com.ai.triptailor.config.OAuth2Properties;
import com.ai.triptailor.exception.UnauthorizedRedirectException;
import com.ai.triptailor.model.UserPrincipal;
import com.ai.triptailor.service.JwtService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.net.URI;

@Component
public class OAuth2LoginSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {
    private final JwtService jwtService;
    private final OAuth2Properties oAuth2Properties;

    @Autowired
    public OAuth2LoginSuccessHandler(
            JwtService jwtService,
            OAuth2Properties oAuth2Properties
    ) {
        this.jwtService = jwtService;
        this.oAuth2Properties = oAuth2Properties;
    }

    @Override
    public void onAuthenticationSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication
    ) throws IOException, ServletException {
        handle(request, response, authentication);
        super.clearAuthenticationAttributes(request);
    }

    @Override
    protected void handle(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException {
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        String token = jwtService.createToken(userPrincipal);

        String targetUrl = determineTargetUrl(request, response, authentication);

        if (!isAuthorizedRedirectUri(targetUrl)) {
            throw new UnauthorizedRedirectException("Not an authorized redirect URI");
        }

        targetUrl = UriComponentsBuilder.fromUriString(targetUrl).queryParam("token", token).build().toUriString();
        getRedirectStrategy().sendRedirect(request, response, targetUrl);
    }

    private boolean isAuthorizedRedirectUri(String uri) {
        URI clientRedirectUri = URI.create(uri);

        return oAuth2Properties.getAuthorizedRedirectUris()
                .stream()
                .anyMatch(authRedirectUri -> {
                    // Only validate host and port. Let the clients use different paths if they want to
                    URI authorizedURI = URI.create(authRedirectUri);
                    if(authorizedURI.getHost().equalsIgnoreCase(clientRedirectUri.getHost())
                            && authorizedURI.getPort() == clientRedirectUri.getPort()) {
                        return true;
                    }
                    return false;
                });
    }

}
