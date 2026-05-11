package com.example.emotionapp.data.dtos

import kotlinx.serialization.Serializable

@Serializable
data class SignInRequestDTO(
    val username: String,
    val password: String
)
