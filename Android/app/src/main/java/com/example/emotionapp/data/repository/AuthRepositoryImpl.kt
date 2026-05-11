package com.example.emotionapp.data.repository

import com.example.emotionapp.data.api.AuthApi
import com.example.emotionapp.data.mappers.toDTO
import com.example.emotionapp.data.network.TokenStorage
import com.example.emotionapp.domain.entities.SignInRequest
import com.example.emotionapp.domain.entities.SignUpRequest
import com.example.emotionapp.domain.repository.AuthRepository
import com.example.emotionapp.utils.NetworkResult
import com.example.emotionapp.utils.safeApiCall
import com.example.emotionapp.utils.toNetworkResult
import javax.inject.Inject

class AuthRepositoryImpl @Inject constructor(
    private val api: AuthApi,
    private val tokenStorage: TokenStorage
): AuthRepository {

    override suspend fun signUp(entity: SignUpRequest): NetworkResult<Unit> {
        val dto = entity.toDTO()
        val response = safeApiCall { api.signUp(dto) }

        return response.toNetworkResult { authDTO ->
            tokenStorage.save(authDTO.token)
        }
    }

    override suspend fun signIn(entity: SignInRequest): NetworkResult<Unit> {
        val dto = entity.toDTO()
        val response = safeApiCall { api.signIn(dto) }

        return response.toNetworkResult { authDTO ->
            tokenStorage.save(authDTO.token)
        }
    }

}