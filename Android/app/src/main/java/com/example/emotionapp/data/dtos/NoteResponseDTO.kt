package com.example.emotionapp.data.dtos

import kotlinx.serialization.Serializable
import java.util.Date

@Serializable
data class NoteCreateDTO(
    val albumId: Long,
    val title: String,
    val content: String
)

@Serializable
data class NoteResponseDTO(
    val id: Long,
    val albumId: Long,
    val title: String,
    val content: String,
    val createdAt: String
)

@Serializable
data class NoteShortDTO(
    val id: Long,
    val title: String,
    val createdAt: String
)

@Serializable
data class NoteUpdateDTO(
    val title: String? = null,
    val content: String? = null
)
