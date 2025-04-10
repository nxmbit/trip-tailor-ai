package com.ai.triptailor.oauth2;

import com.ai.triptailor.config.OAuth2Properties;
import com.ai.triptailor.exception.UnauthorizedRedirectException;
import com.ai.triptailor.model.RefreshToken;
import com.ai.triptailor.model.UserPrincipal;
import com.ai.triptailor.service.JwtService;
import com.ai.triptailor.service.RefreshTokenService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URI;

@Component
public class OAuth2LoginSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {
    private final JwtService jwtService;
    private final OAuth2Properties oAuth2Properties;
    private final RefreshTokenService refreshTokenService;

    @Autowired
    public OAuth2LoginSuccessHandler(
            JwtService jwtService,
            OAuth2Properties oAuth2Properties,
            RefreshTokenService refreshTokenService
    ) {
        this.jwtService = jwtService;
        this.oAuth2Properties = oAuth2Properties;
        this.refreshTokenService = refreshTokenService;
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
        String jwtToken = jwtService.createToken(userPrincipal);
        refreshTokenService.deleteByUserId(userPrincipal.getId());
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(userPrincipal.getId());

        String targetUrl = determineTargetUrl(request, response, authentication);

        if (!isAuthorizedRedirectUri(targetUrl) && !targetUrl.equals("/")) {
            throw new UnauthorizedRedirectException("Not an authorized redirect URI");
        }

        // TODO: handle mobile clients, asses whether sending query params is safe

        // Set the JWT and refresh token as HttpOnly cookies
        // These are only meant for token transfer to the client
        Cookie accessTokenCookie = new Cookie("access_token", jwtToken);
        accessTokenCookie.setHttpOnly(true);
        accessTokenCookie.setSecure(true);
        accessTokenCookie.setPath("/");
        accessTokenCookie.setMaxAge(300); // 5 min
        response.addCookie(accessTokenCookie);

        Cookie refreshTokenCookie = new Cookie("refresh_token", refreshToken.getToken());
        refreshTokenCookie.setHttpOnly(true);
        refreshTokenCookie.setSecure(true);
        refreshTokenCookie.setPath("/");
        refreshTokenCookie.setMaxAge(300); // 5 min
        response.addCookie(refreshTokenCookie);

        getRedirectStrategy().sendRedirect(request, response, targetUrl);
    }

    private boolean isAuthorizedRedirectUri(String uri) {
        URI clientRedirectUri = URI.create(uri);

        return oAuth2Properties.getAuthorizedRedirectUris()
                .stream()
                .anyMatch(authRedirectUri -> {
                    // Only validate host and port. Let the clients use different paths if they want to
                    URI authorizedURI = URI.create(authRedirectUri);
                    return authorizedURI.getHost().equalsIgnoreCase(clientRedirectUri.getHost())
                            && authorizedURI.getPort() == clientRedirectUri.getPort();
                });
    }

}
