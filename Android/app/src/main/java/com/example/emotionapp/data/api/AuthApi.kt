package com.example.emotionapp.data.api

import com.example.emotionapp.data.dtos.AuthResponseDTO
import com.example.emotionapp.data.dtos.SignInRequestDTO
import com.example.emotionapp.data.dtos.SignUpRequestDTO
import retrofit2.Response
import retrofit2.http.*

interface AuthApi {

    @POST("auth/sign-up")
    suspend fun signUp(
        @Body body: SignUpRequestDTO
    ): Response<AuthResponseDTO>

    @POST("auth/sign-in")
    suspend fun signIn(
        @Body body: SignInRequestDTO
    ): Response<AuthResponseDTO>
}