package com.example.emotionapp.domain.entities

data class Note(
    val id: Long,
    val albumId: Long,
    val title: String,
    val content: String,
    val createdAt: String
)
