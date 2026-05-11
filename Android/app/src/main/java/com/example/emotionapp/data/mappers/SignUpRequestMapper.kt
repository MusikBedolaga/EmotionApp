package com.example.emotionapp.data.mappers

import com.example.emotionapp.data.dtos.SignUpRequestDTO
import com.example.emotionapp.domain.entities.SignUpRequest

fun SignUpRequest.toDTO(): SignUpRequestDTO = SignUpRequestDTO(
    username = username,
    email = email,
    password = password,
    age = age
)