package com.example.emotionapp.domain.repository

import com.example.emotionapp.domain.entities.Topic
import com.example.emotionapp.utils.NetworkResult

interface TopicRepository {
    suspend fun getAllTopics(): NetworkResult<List<Topic>>
}