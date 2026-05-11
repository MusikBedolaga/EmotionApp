package com.example.emotionapp.data.api

import com.example.emotionapp.data.dtos.TopicShortDTO
import retrofit2.Response
import retrofit2.http.*

interface TopicApi {

    @GET("content/topics")
    suspend fun getAllTopics(): Response<List<TopicShortDTO>>
}