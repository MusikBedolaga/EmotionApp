package com.example.emotionapp.data.repository

import com.example.emotionapp.data.api.AiApi
import com.example.emotionapp.data.dtos.AlbumEmotionAnalysisDTO
import com.example.emotionapp.data.dtos.AnalyzePeriodRequestDTO
import com.example.emotionapp.data.dtos.EmotionCountsDTO
import com.example.emotionapp.data.dtos.EmotionScoresDTO
import com.example.emotionapp.data.dtos.TopicEmotionDTO
import com.example.emotionapp.data.network.TokenStorage
import com.example.emotionapp.domain.entities.AlbumEmotionAnalysis
import com.example.emotionapp.domain.entities.EmotionCounts
import com.example.emotionapp.domain.entities.EmotionScores
import com.example.emotionapp.domain.entities.TopicEmotionAnalysis
import com.example.emotionapp.domain.repository.AiRepository
import com.example.emotionapp.utils.NetworkResult
import com.example.emotionapp.utils.safeApiCall
import com.example.emotionapp.utils.toNetworkResult
import java.time.Instant
import javax.inject.Inject

class AiRepositoryImpl @Inject constructor(
    private val api: AiApi,
    private val tokenStorage: TokenStorage
) : AiRepository {

    override suspend fun analyzeAlbumPeriod(
        albumId: Long,
        periodFrom: Instant,
        periodTo: Instant,
        periodType: String
    ): NetworkResult<AlbumEmotionAnalysis> {
        val userId = tokenStorage.getUserId()
            ?: return NetworkResult.Error.Unknown("Не удалось определить пользователя из токена")

        val response = safeApiCall {
            api.analyzeAlbumPeriod(
                albumId = albumId,
                userId = userId,
                body = AnalyzePeriodRequestDTO(
                    periodFrom = periodFrom.toString(),
                    periodTo = periodTo.toString(),
                    periodType = periodType
                )
            )
        }
        return response.toNetworkResult { it.toDomain() }
    }

    override suspend fun getTopicEmotion(
        topicId: Long,
        periodFrom: Instant,
        periodTo: Instant
    ): NetworkResult<TopicEmotionAnalysis> {
        val userId = tokenStorage.getUserId()
            ?: return NetworkResult.Error.Unknown("Не удалось определить пользователя из токена")

        val response = safeApiCall {
            api.getTopicEmotion(
                topicId = topicId,
                userId = userId,
                from = periodFrom.toString(),
                to = periodTo.toString()
            )
        }
        return response.toNetworkResult { it.toDomain() }
    }
}

private fun AlbumEmotionAnalysisDTO.toDomain(): AlbumEmotionAnalysis = AlbumEmotionAnalysis(
    albumId = albumId,
    summary = resultJson.summary,
    topWords = resultJson.topWords,
    emotionDistribution = resultJson.emotionDistribution.toDomain(),
    dominantEmotion = resultJson.dominantEmotion,
    valence = resultJson.valence,
    confidence = resultJson.confidence,
    noteEmotionCounts = resultJson.noteEmotionCounts.toDomain(),
    modelBackend = resultJson.modelBackend
)

private fun TopicEmotionDTO.toDomain(): TopicEmotionAnalysis = TopicEmotionAnalysis(
    topicId = topicId,
    name = name,
    color = color,
    noteCount = noteCount,
    summary = summary,
    topWords = topWords,
    emotionDistribution = emotionDistribution.toDomain(),
    dominantEmotion = dominantEmotion,
    valence = valence,
    confidence = confidence,
    modelBackend = modelBackend
)

private fun EmotionScoresDTO.toDomain(): EmotionScores = EmotionScores(
    joy = joy,
    sadness = sadness,
    anger = anger,
    fear = fear,
    surprise = surprise,
    neutral = neutral
)

private fun EmotionCountsDTO.toDomain(): EmotionCounts = EmotionCounts(
    joy = joy,
    sadness = sadness,
    anger = anger,
    fear = fear,
    surprise = surprise,
    neutral = neutral
)
