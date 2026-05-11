package com.example.auth_service.controllers;


import com.example.auth_service.services.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/example")
@RequiredArgsConstructor
@Tag(name = "Аутентификация")
public class TestController {
    private final UserService service;

    @GetMapping("/2")
    @Operation(summary = "Доступен только авторизованным пользователям")
    public String example() {
        return "Hello, user!";
    }

    @GetMapping("/1")
    @Operation(summary = "Доступен всем")
    public String example1() {
        return "Hello world";
    }
}