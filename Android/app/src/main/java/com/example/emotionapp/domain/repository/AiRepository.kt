package com.example.emotionapp.domain.repository

import com.example.emotionapp.domain.entities.AlbumEmotionAnalysis
import com.example.emotionapp.domain.entities.TopicEmotionAnalysis
import com.example.emotionapp.utils.NetworkResult
import java.time.Instant

interface AiRepository {
    suspend fun analyzeAlbumPeriod(
        albumId: Long,
        periodFrom: Instant,
        periodTo: Instant,
        periodType: String
    ): NetworkResult<AlbumEmotionAnalysis>

    suspend fun getTopicEmotion(
        topicId: Long,
        periodFrom: Instant,
        periodTo: Instant
    ): NetworkResult<TopicEmotionAnalysis>
}
