package com.example.emotionapp.data.repository.fake


import com.example.emotionapp.data.mock.MockTopics
import com.example.emotionapp.data.mappers.toDomain
import com.example.emotionapp.domain.entities.Topic
import com.example.emotionapp.domain.repository.TopicRepository
import com.example.emotionapp.utils.NetworkResult
import kotlinx.coroutines.delay
import javax.inject.Inject

class FakeTopicRepository @Inject constructor() : TopicRepository {

    override suspend fun getAllTopics(): NetworkResult<List<Topic>> {
        delay(150)

        val result = MockTopics.topicsResponse
            .map { it.toDomain() }

        return NetworkResult.Ok(result)
    }
}
