package com.example.emotionapp.data.repository

import com.example.emotionapp.data.api.TopicApi
import com.example.emotionapp.data.mappers.toDomain
import com.example.emotionapp.domain.entities.Topic
import com.example.emotionapp.domain.repository.TopicRepository
import com.example.emotionapp.utils.NetworkResult
import com.example.emotionapp.utils.safeApiCall
import com.example.emotionapp.utils.toNetworkResult
import javax.inject.Inject

class TopicRepositoryImpl @Inject constructor(
    private val api: TopicApi
): TopicRepository {
    override suspend fun getAllTopics(): NetworkResult<List<Topic>> {
        val response = safeApiCall { api.getAllTopics() }

        return response.toNetworkResult { list ->
            list.map { it.toDomain() }
        }
    }
}
