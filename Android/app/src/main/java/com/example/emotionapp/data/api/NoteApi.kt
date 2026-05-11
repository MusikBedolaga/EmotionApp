package com.example.emotionapp.data.api

import com.example.emotionapp.data.dtos.NoteCreateDTO
import com.example.emotionapp.data.dtos.NoteResponseDTO
import com.example.emotionapp.data.dtos.NoteShortDTO
import retrofit2.Response
import retrofit2.http.*

interface NoteApi {

    @POST("content/notes/create-note")
    suspend fun createNote(
        @Body body: NoteCreateDTO
    ): Response<NoteResponseDTO>

    @GET("content/notes/{id}")
    suspend fun getNote(
        @Path("id") id: Long
    ): Response<NoteResponseDTO>

    @GET("content/notes/album/{albumId}")
    suspend fun getNotesByAlbum(
        @Path("albumId") albumId: Long
    ): Response<List<NoteShortDTO>>

    @DELETE("content/notes/{id}")
    suspend fun deleteNote(
        @Path("id") id: Long
    ): Response<Unit>
}
