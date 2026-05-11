package com.example.emotionapp.data.mock

import com.example.emotionapp.data.dtos.*

object MockTopics {

    val topicsResponse = listOf(
        TopicResponseDTO(1L, "work", "#7C4DFF"),
        TopicResponseDTO(2L, "health", "#00C853"),
        TopicResponseDTO(3L, "ideas", "#FF6D00"),
        TopicResponseDTO(4L, "personal", "#03A9F4")
    )

    val topicsShort = topicsResponse.map {
        TopicShortDTO(
            id = it.id,
            name = it.name,
            color = it.color
        )
    }
}
