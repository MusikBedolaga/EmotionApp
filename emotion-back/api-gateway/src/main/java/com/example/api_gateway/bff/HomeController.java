package com.example.api_gateway.bff;

import com.example.api_gateway.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/bff")
@RequiredArgsConstructor
public class HomeController {

    private final HomeService homeService;
    private final JwtService jwtService;

    @GetMapping("/home")
    public Mono<HomeResponse> getHome(
            @org.springframework.web.bind.annotation.RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
            @RequestParam(defaultValue = "5") int recentNotesLimit
    ) {
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing bearer token");
        }

        String token = authorization.substring("Bearer ".length());
        Long userId = jwtService.extractUserId(token);
        if (userId == null || !jwtService.isTokenValid(token)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token");
        }

        return homeService.loadHome(userId, recentNotesLimit);
    }
}
