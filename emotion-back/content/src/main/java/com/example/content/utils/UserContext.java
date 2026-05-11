package com.example.content.utils;

import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

@Component
public class UserContext {

    public Long getUserId(ServerHttpRequest request) {
        String value = request.getHeaders().getFirst("X-User-Id");
        if (value == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }
        return Long.valueOf(value);
    }
}
