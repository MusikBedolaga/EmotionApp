package com.example.emotionapp.data.mock

import com.example.emotionapp.data.dtos.*

object MockAlbums {

    val albumsResponse = listOf(
        AlbumResponseDTO(
            id = 1L,
            title = "January Recap",
            description = "Weekly notes and analysis",
            createdAt = "2026-01-10T12:00:00Z",
            topics = listOf(
                TopicResponseDTO(1L, "work", "#7C4DFF"),
                TopicResponseDTO(2L, "health", "#00C853")
            )
        ),
        AlbumResponseDTO(
            id = 2L,
            title = "Ideas",
            description = "Random thoughts and drafts",
            createdAt = "2026-01-12T08:30:00Z",
            topics = listOf(
                TopicResponseDTO(3L, "ideas", "#FF6D00")
            )
        )
    )

    val albumsShort = listOf(
        AlbumShortDTO(
            id = 1L,
            title = "January Recap",
            description = "Weekly notes and analysis",
            notesCount = 2
        ),
        AlbumShortDTO(
            id = 2L,
            title = "Ideas",
            description = "Random thoughts and drafts",
            notesCount = 1
        )
    )
}
