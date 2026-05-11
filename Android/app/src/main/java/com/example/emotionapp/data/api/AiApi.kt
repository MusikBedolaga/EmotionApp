package com.example.emotionapp.data.api

import com.example.emotionapp.data.dtos.AlbumEmotionAnalysisDTO
import com.example.emotionapp.data.dtos.AnalyzePeriodRequestDTO
import com.example.emotionapp.data.dtos.TopicEmotionDTO
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.POST
import retrofit2.http.Path
import retrofit2.http.Query

interface AiApi {

    @POST("api/ai/albums/{albumId}:analyze-period")
    suspend fun analyzeAlbumPeriod(
        @Path("albumId") albumId: Long,
        @Header("X-User-Id") userId: Long,
        @Body body: AnalyzePeriodRequestDTO
    ): Response<AlbumEmotionAnalysisDTO>

    @GET("api/ai/topics/{topicId}/emotion")
    suspend fun getTopicEmotion(
        @Path("topicId") topicId: Long,
        @Header("X-User-Id") userId: Long,
        @Query("from") from: String,
        @Query("to") to: String,
        @Query("model") model: String = "emotion-zero-shot-v1"
    ): Response<TopicEmotionDTO>
}
