package com.example.emotionapp.data.mock

import com.example.emotionapp.data.dtos.*

object MockNotes {

    val notesResponse = listOf(
        NoteResponseDTO(
            id = 100L,
            albumId = 1L,
            title = "Week 1",
            content = "Focused on onboarding and bug fixes.",
            createdAt = "2026-01-11T09:00:00Z"
        ),
        NoteResponseDTO(
            id = 101L,
            albumId = 1L,
            title = "Week 2",
            content = "Refactored ViewModels, added tests.",
            createdAt = "2026-01-18T09:00:00Z"
        ),
        NoteResponseDTO(
            id = 102L,
            albumId = 2L,
            title = "App idea",
            content = "Mood tracking app with weekly summaries.",
            createdAt = "2026-01-13T14:20:00Z"
        )
    )

    fun notesByAlbum(albumId: Long): List<NoteResponseDTO> =
        notesResponse.filter { it.albumId == albumId }

    fun notesShortByAlbum(albumId: Long): List<NoteShortDTO> =
        notesByAlbum(albumId).map {
            NoteShortDTO(
                id = it.id,
                title = it.title,
                createdAt = it.createdAt
            )
        }
}
