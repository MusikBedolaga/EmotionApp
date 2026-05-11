package com.example.emotionapp.data.repository.fake

import com.example.emotionapp.data.mappers.toDomain
import com.example.emotionapp.data.mock.MockAlbums
import com.example.emotionapp.domain.entities.Album
import com.example.emotionapp.domain.entities.AlbumSummary
import com.example.emotionapp.domain.repository.AlbumRepository
import com.example.emotionapp.utils.NetworkResult
import kotlinx.coroutines.delay
import javax.inject.Inject

class FakeAlbumRepository @Inject constructor() : AlbumRepository {

    override suspend fun createAlbum(
        title: String,
        description: String
    ): NetworkResult<Album> {
        delay(200)

        val album = MockAlbums.albumsResponse.first()
            .copy(title = title, description = description)

        return NetworkResult.Ok(album.toDomain())
    }

    override suspend fun getAlbum(id: Long): NetworkResult<Album> {
        delay(200)

        val album = MockAlbums.albumsResponse.find { it.id == id }
            ?: return NetworkResult.Error.Network("Album not found")

        return NetworkResult.Ok(album.toDomain())
    }

    override suspend fun updateAlbum(entity: Album): NetworkResult<Album> {
        delay(200)

        return NetworkResult.Ok(entity)
    }

    override suspend fun deleteAlbum(id: Long): NetworkResult<Unit> {
        delay(150)
        return NetworkResult.Ok(Unit)
    }

    override suspend fun getAlbumsByTopic(topicId: Long): NetworkResult<List<AlbumSummary>> {
        delay(200)

        val result = MockAlbums.albumsResponse
            .filter { album ->
                album.topics.any { it.id == topicId }
            }
            .map { it.toDomain() as AlbumSummary }

        return NetworkResult.Ok(result)
    }

    override suspend fun getAllAlbums(): NetworkResult<List<Album>> {
        delay(200)

        val result = MockAlbums.albumsResponse
            .map { it.toDomain() }

        return NetworkResult.Ok(result)
    }
}