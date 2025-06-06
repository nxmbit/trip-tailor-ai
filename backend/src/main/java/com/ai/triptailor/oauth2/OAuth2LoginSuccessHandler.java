package com.ai.triptailor.oauth2;

import com.ai.triptailor.config.ClientProperties;
import com.ai.triptailor.model.RefreshToken;
import com.ai.triptailor.model.UserPrincipal;
import com.ai.triptailor.service.JwtService;
import com.ai.triptailor.service.RefreshTokenService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import java.io.IOException;

@Component
public class OAuth2LoginSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {
    @Value("${security.oauth2.webRedirectUri}")
    private String redirectUri;

    @Value("${security.oauth2.mobileRedirectUri:}")
    private String mobileRedirectUri;

    private final RefreshTokenService refreshTokenService;
    private final ClientProperties clientProperties;

    @Autowired
    public OAuth2LoginSuccessHandler(
            RefreshTokenService refreshTokenService,
            ClientProperties clientProperties
    ) {
        this.refreshTokenService = refreshTokenService;
        this.clientProperties = clientProperties;
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
        refreshTokenService.deleteByUserId(userPrincipal.getId());
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(userPrincipal.getId());

        if (ClientProperties.ClientType.MOBILE == clientProperties.getType()) {
            String redirectUri = this.mobileRedirectUri + "?refresh_token=" + refreshToken.getToken();

            getRedirectStrategy().sendRedirect(request, response, redirectUri);
        } else {
            // Set the refresh token as HttpOnly cookie for web clients
            // it is only meant for token transfer to the client
            Cookie refreshTokenCookie = new Cookie("refresh_token", refreshToken.getToken());
            refreshTokenCookie.setHttpOnly(true);
            refreshTokenCookie.setSecure(false);
            refreshTokenCookie.setPath("/");
            refreshTokenCookie.setMaxAge(300); // 5 min
            response.addCookie(refreshTokenCookie);

            getRedirectStrategy().sendRedirect(request, response, redirectUri);
        }


    }
}