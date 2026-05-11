package com.example.emotionapp.domain.repository

import com.example.emotionapp.domain.entities.SignInRequest
import com.example.emotionapp.domain.entities.SignUpRequest
import com.example.emotionapp.utils.NetworkResult

interface AuthRepository {
    suspend fun signUp(entity: SignUpRequest): NetworkResult<Unit>
    suspend fun signIn(entity: SignInRequest): NetworkResult<Unit>
}