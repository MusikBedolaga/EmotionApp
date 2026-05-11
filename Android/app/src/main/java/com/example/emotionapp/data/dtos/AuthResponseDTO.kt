package com.example.emotionapp.data.dtos

import kotlinx.serialization.Serializable

@Serializable
data class AuthResponseDTO(
    val token: String
)
