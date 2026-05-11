package com.example.emotionapp.domain.entities

data class Album(
    val id: Long,
    val title: String,
    val description: String,
    val createdAt: String,
    val topics: List<Topic>,
    val notesCount: Int? = null
)
