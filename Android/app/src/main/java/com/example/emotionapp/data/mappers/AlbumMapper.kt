package com.example.emotionapp.data.mappers

import com.example.emotionapp.data.dtos.AlbumResponseDTO
import com.example.emotionapp.data.dtos.AlbumShortDTO
import com.example.emotionapp.domain.entities.Album
import com.example.emotionapp.domain.entities.AlbumSummary

fun AlbumResponseDTO.toDomain(): Album = Album(
    id = id,
    title = title,
    description = description,
    createdAt = createdAt,
    topics = topics.map { it.toDomain() },
    notesCount = null
)

fun Album.toDTO(): AlbumResponseDTO = AlbumResponseDTO(
    id = id,
    title = title,
    description = description,
    createdAt = createdAt,
    topics = topics.map { it.toDTO() },
)

fun AlbumShortDTO.toDomain(): AlbumSummary = AlbumSummary(
    id = id,
    title = title,
    description = description,
    notesCount = notesCount
)
