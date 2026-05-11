package com.example.emotionapp.data.mappers

import com.example.emotionapp.data.dtos.SignInRequestDTO
import com.example.emotionapp.domain.entities.SignInRequest

fun SignInRequest.toDTO(): SignInRequestDTO = SignInRequestDTO(
    username = username,
    password = password
)