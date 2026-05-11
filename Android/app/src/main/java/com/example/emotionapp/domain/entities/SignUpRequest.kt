package com.example.emotionapp.domain.entities

data class SignUpRequest(
    val username: String,
    val email: String,
    val password: String,
    /** Возраст обязателен на бэкенде; в UI пока нет поля — отправляем безопасное значение по умолчанию. */
    val age: Int = 25
)
