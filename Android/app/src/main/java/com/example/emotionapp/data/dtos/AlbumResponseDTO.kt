package com.example.emotionapp.data.dtos

import kotlinx.serialization.Serializable

@Serializable
data class AlbumCreateDTO(
    val title: String,
    val description: String
)

@Serializable
data class AlbumResponseDTO(
    val id: Long,
    val title: String,
    val description: String,
    val createdAt: String,
    val topics: List<TopicResponseDTO>,
)

@Serializable
data class AlbumShortDTO(
    val id: Long,
    val title: String,
    val description: String,
    val notesCount: Int
)

@Serializable
data class AlbumUpdateDTO(
    val title: String? = null,
    val description: String? = null
)
