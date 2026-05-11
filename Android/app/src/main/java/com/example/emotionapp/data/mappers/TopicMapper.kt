package com.example.emotionapp.data.mappers

import com.example.emotionapp.data.dtos.TopicResponseDTO
import com.example.emotionapp.data.dtos.TopicShortDTO
import com.example.emotionapp.domain.entities.Topic

fun TopicResponseDTO.toDomain(): Topic = Topic(
    id = id,
    name = name,
    color = color
)

fun Topic.toDTO(): TopicResponseDTO = TopicResponseDTO(
    id = id,
    name = name,
    color = color
)

fun TopicShortDTO.toDomain(): Topic = Topic(
    id = id,
    name = name,
    color = color
)
