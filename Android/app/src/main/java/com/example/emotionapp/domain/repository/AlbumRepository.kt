package com.example.emotionapp.domain.repository

import com.example.emotionapp.domain.entities.Album
import com.example.emotionapp.domain.entities.AlbumSummary
import com.example.emotionapp.utils.NetworkResult

interface AlbumRepository {
    suspend fun createAlbum(title: String, description: String): NetworkResult<Album>
    suspend fun getAlbum(id: Long): NetworkResult<Album>
    suspend fun updateAlbum(entity: Album): NetworkResult<Album>
    suspend fun deleteAlbum(id: Long): NetworkResult<Unit>
    suspend fun getAlbumsByTopic(topicId: Long): NetworkResult<List<AlbumSummary>>
    suspend fun getAllAlbums(): NetworkResult<List<Album>>
}
