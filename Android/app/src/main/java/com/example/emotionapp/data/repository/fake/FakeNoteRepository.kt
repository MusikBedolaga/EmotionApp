package com.example.emotionapp.data.repository.fake

import com.example.emotionapp.data.mock.MockNotes
import com.example.emotionapp.data.mappers.toDomain
import com.example.emotionapp.domain.entities.Note
import com.example.emotionapp.domain.entities.NoteSummary
import com.example.emotionapp.domain.repository.NoteRepository
import com.example.emotionapp.utils.NetworkResult
import kotlinx.coroutines.delay
import javax.inject.Inject

class FakeNoteRepository @Inject constructor() : NoteRepository {

    override suspend fun createNote(
        albumId: Long,
        title: String,
        content: String
    ): NetworkResult<Note> {
        delay(150)

        val note = MockNotes.notesResponse.first()
            .copy(
                albumId = albumId,
                title = title,
                content = content
            )

        return NetworkResult.Ok(note.toDomain())
    }

    override suspend fun getNote(id: Long): NetworkResult<Note> {
        delay(150)

        val note = MockNotes.notesResponse.find { it.id == id }
            ?: return NetworkResult.Error.Network("Note not found")

        return NetworkResult.Ok(note.toDomain())
    }

    override suspend fun getNotesByAlbum(albumId: Long): NetworkResult<List<NoteSummary>> {
        delay(200)

        val result: List<NoteSummary> = MockNotes
            .notesShortByAlbum(albumId)
            .map { it.toDomain() }

        return NetworkResult.Ok(result)
    }

    override suspend fun deleteNote(id: Long): NetworkResult<Unit> {
        delay(100)
        return NetworkResult.Ok(Unit)
    }
}
