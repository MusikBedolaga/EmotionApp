package com.example.emotionapp.data.api

import com.example.emotionapp.data.dtos.AlbumCreateDTO
import com.example.emotionapp.data.dtos.AlbumResponseDTO
import com.example.emotionapp.data.dtos.AlbumShortDTO
import com.example.emotionapp.data.dtos.AlbumUpdateDTO
import retrofit2.Response
import retrofit2.http.*

interface AlbumApi {

    @POST("content/albums/create-album")
    suspend fun createAlbum(
        @Body body: AlbumCreateDTO
    ): Response<AlbumResponseDTO>

    @GET("content/albums/{id}")
    suspend fun getAlbum(
        @Path("id") id: Long
    ): Response<AlbumResponseDTO>

    @PATCH("content/albums/{id}")
    suspend fun updateAlbum(
        @Path("id") id: Long,
        @Body body: AlbumUpdateDTO
    ): Response<AlbumResponseDTO>

    @DELETE("content/albums/{id}")
    suspend fun deleteAlbum(
        @Path("id") id: Long
    ): Response<Unit>

    @GET("content/albums/by-topic/{topicId}")
    suspend fun getAlbumsByTopic(
        @Path("topicId") topicId: Long
    ): Response<List<AlbumShortDTO>>

    @GET("content/albums/all-albums")
    suspend fun getAllAlbums(): Response<List<AlbumResponseDTO>>
}