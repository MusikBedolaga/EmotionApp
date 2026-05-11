package com.example.emotionapp.data.dtos

import kotlinx.serialization.Serializable

@Serializable
data class SignUpRequestDTO(
    val username: String,
    val email: String,
    val password: String,
    val age: Int
)
