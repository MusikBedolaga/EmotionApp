package com.example.emotionapp.data.mappers

import com.example.emotionapp.data.dtos.AlbumResponseDTO
import com.example.emotionapp.data.dtos.AlbumShortDTO
import com.example.emotionapp.data.dtos.TopicResponseDTO
import org.junit.Assert.assertEquals
import org.junit.Test

class AlbumMapperTest {

    @Test
    fun albumResponseDto_toDomain_mapsFieldsAndTopics() {
        val dto = AlbumResponseDTO(
            id = 42L,
            title = "Дневник",
            description = "Заметки",
            createdAt = "2025-01-15T12:00:00",
            topics = listOf(
                TopicResponseDTO(id = 1L, name = "Работа", color = "#FF0000")
            )
        )

        val album = dto.toDomain()

        assertEquals(42L, album.id)
        assertEquals("Дневник", album.title)
        assertEquals("Заметки", album.description)
        assertEquals("2025-01-15T12:00:00", album.createdAt)
        assertEquals(1, album.topics.size)
        assertEquals(1L, album.topics[0].id)
        assertEquals("Работа", album.topics[0].name)
        assertEquals("#FF0000", album.topics[0].color)
        assertEquals(null, album.notesCount)
    }

    @Test
    fun albumShortDto_toDomain_mapsNotesCount() {
        val dto = AlbumShortDTO(
            id = 7L,
            title = "Краткий",
            description = "Описание",
            notesCount = 5
        )

        val summary = dto.toDomain()

        assertEquals(7L, summary.id)
        assertEquals("Краткий", summary.title)
        assertEquals("Описание", summary.description)
        assertEquals(5, summary.notesCount)
    }
}
