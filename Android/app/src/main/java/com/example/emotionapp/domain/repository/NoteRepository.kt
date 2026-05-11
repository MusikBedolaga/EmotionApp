package com.example.emotionapp.domain.repository

import com.example.emotionapp.domain.entities.Note
import com.example.emotionapp.domain.entities.NoteSummary
import com.example.emotionapp.utils.NetworkResult

interface NoteRepository {
    suspend fun createNote(
        albumId: Long,
        title: String,
        content: String
    ): NetworkResult<Note>
    suspend fun getNote(id: Long): NetworkResult<Note>
    suspend fun getNotesByAlbum(albumId: Long): NetworkResult<List<NoteSummary>>
    suspend fun deleteNote(id: Long): NetworkResult<Unit>
}
