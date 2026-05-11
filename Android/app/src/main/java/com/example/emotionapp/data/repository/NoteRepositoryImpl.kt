package com.example.emotionapp.data.repository

import com.example.emotionapp.data.api.NoteApi
import com.example.emotionapp.data.dtos.NoteCreateDTO
import com.example.emotionapp.data.mappers.toDomain
import com.example.emotionapp.domain.entities.Note
import com.example.emotionapp.domain.entities.NoteSummary
import com.example.emotionapp.domain.repository.NoteRepository
import com.example.emotionapp.utils.NetworkResult
import com.example.emotionapp.utils.safeApiCall
import com.example.emotionapp.utils.toNetworkResult
import javax.inject.Inject

class NoteRepositoryImpl @Inject constructor(
    private val api: NoteApi
): NoteRepository {

    override suspend fun createNote(
        albumId: Long,
        title: String,
        content: String
    ): NetworkResult<Note> {
        val dto = NoteCreateDTO(
            albumId,
            title,
            content
        )
        val response = safeApiCall { api.createNote(dto) }

        return response.toNetworkResult { it.toDomain() }
    }

    override suspend fun getNote(id: Long): NetworkResult<Note> {
        val result = safeApiCall { api.getNote(id) }

        return result.toNetworkResult { it.toDomain() }
    }

    override suspend fun getNotesByAlbum(albumId: Long): NetworkResult<List<NoteSummary>> {
        val response = safeApiCall { api.getNotesByAlbum(albumId) }

        return response.toNetworkResult { list ->
            list.map { it.toDomain() }
        }
    }

    override suspend fun deleteNote(id: Long): NetworkResult<Unit> {
        val response = safeApiCall { api.deleteNote(id) }

        return response.toNetworkResult { it }
    }
}
