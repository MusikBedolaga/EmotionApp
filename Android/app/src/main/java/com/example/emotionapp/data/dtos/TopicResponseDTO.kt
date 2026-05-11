package com.example.emotionapp.data.dtos

import kotlinx.serialization.Serializable

@Serializable
data class TopicResponseDTO(
    val id: Long,
    val name: String,
    val color: String
)

@Serializable
data class TopicShortDTO(
    val id: Long,
    val name: String,
    val color: String
)
