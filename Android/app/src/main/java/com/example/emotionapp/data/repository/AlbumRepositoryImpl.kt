package com.example.emotionapp.data.repository

import com.example.emotionapp.data.api.AlbumApi
import com.example.emotionapp.data.dtos.AlbumCreateDTO
import com.example.emotionapp.data.dtos.AlbumUpdateDTO
import com.example.emotionapp.data.mappers.toDomain
import com.example.emotionapp.domain.entities.Album
import com.example.emotionapp.domain.entities.AlbumSummary
import com.example.emotionapp.domain.repository.AlbumRepository
import com.example.emotionapp.utils.NetworkResult
import com.example.emotionapp.utils.safeApiCall
import com.example.emotionapp.utils.toNetworkResult
import javax.inject.Inject

class AlbumRepositoryImpl @Inject constructor(
    private val api: AlbumApi
): AlbumRepository {

    override suspend fun createAlbum(
        title: String,
        description: String
    ): NetworkResult<Album> {
        val dto = AlbumCreateDTO(title, description)
        val response = safeApiCall { api.createAlbum(dto) }

        return response.toNetworkResult { it.toDomain() }
    }

    override suspend fun getAlbum(id: Long): NetworkResult<Album> {
        val response = safeApiCall { api.getAlbum(id) }

        return response.toNetworkResult { it.toDomain() }
    }

    override suspend fun updateAlbum(entity: Album): NetworkResult<Album> {
        val dto = AlbumUpdateDTO(entity.title, entity.description)
        val response = safeApiCall { api.updateAlbum(entity.id, dto) }

        return response.toNetworkResult { it.toDomain() }
    }

    override suspend fun deleteAlbum(id: Long): NetworkResult<Unit> {
        val response = safeApiCall { api.deleteAlbum(id) }

        return response.toNetworkResult { it }
    }

    override suspend fun getAlbumsByTopic(topicId: Long): NetworkResult<List<AlbumSummary>> {
        val response = safeApiCall { api.getAlbumsByTopic(topicId) }

        return response.toNetworkResult { list ->
            list.map { it.toDomain() }
        }
    }

    override suspend fun getAllAlbums(): NetworkResult<List<Album>> {
        val response = safeApiCall { api.getAllAlbums() }

        return response.toNetworkResult { list ->
            list.map { it.toDomain() }
        }
    }
}