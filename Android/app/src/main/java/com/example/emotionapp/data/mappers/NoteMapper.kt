package com.example.emotionapp.data.mappers

import com.example.emotionapp.data.dtos.NoteResponseDTO
import com.example.emotionapp.data.dtos.NoteShortDTO
import com.example.emotionapp.domain.entities.Note
import com.example.emotionapp.domain.entities.NoteSummary

fun NoteResponseDTO.toDomain(): Note = Note(
    id = id,
    albumId = albumId,
    title = title,
    content = content,
    createdAt = createdAt
)

fun Note.toDTO(): NoteResponseDTO = NoteResponseDTO(
    id = id,
    albumId = albumId,
    title = title,
    content = content,
    createdAt = createdAt
)

fun NoteShortDTO.toDomain(): NoteSummary = NoteSummary(
    id = id,
    title = title,
    createdAt = createdAt
)
