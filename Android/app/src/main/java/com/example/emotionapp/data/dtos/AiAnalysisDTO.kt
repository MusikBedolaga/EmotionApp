package com.example.emotionapp.data.dtos

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class AnalyzePeriodRequestDTO(
    @SerialName("period_from") val periodFrom: String,
    @SerialName("period_to") val periodTo: String,
    @SerialName("period_type") val periodType: String,
    @SerialName("analysis_type") val analysisType: String = "emotion_period_report",
    val model: String = "emotion-zero-shot-v1"
)

@Serializable
data class EmotionScoresDTO(
    val joy: Double = 0.0,
    val sadness: Double = 0.0,
    val anger: Double = 0.0,
    val fear: Double = 0.0,
    val surprise: Double = 0.0,
    val neutral: Double = 0.0
)

@Serializable
data class EmotionCountsDTO(
    val joy: Int = 0,
    val sadness: Int = 0,
    val anger: Int = 0,
    val fear: Int = 0,
    val surprise: Int = 0,
    val neutral: Int = 0
)

@Serializable
data class AlbumEmotionResultDTO(
    val summary: String? = null,
    @SerialName("top_words") val topWords: List<String> = emptyList(),
    @SerialName("emotion_distribution") val emotionDistribution: EmotionScoresDTO = EmotionScoresDTO(),
    @SerialName("dominant_emotion") val dominantEmotion: String = "neutral",
    val valence: String = "neutral",
    val confidence: Double = 0.0,
    @SerialName("note_emotion_counts") val noteEmotionCounts: EmotionCountsDTO = EmotionCountsDTO(),
    @SerialName("model_backend") val modelBackend: String = "heuristic-v1"
)

@Serializable
data class AlbumEmotionAnalysisDTO(
    val id: Long,
    @SerialName("album_id") val albumId: Long,
    @SerialName("result_json") val resultJson: AlbumEmotionResultDTO = AlbumEmotionResultDTO()
)

@Serializable
data class TopicEmotionDTO(
    @SerialName("topic_id") val topicId: Long,
    val name: String,
    val color: String,
    @SerialName("note_count") val noteCount: Int,
    val summary: String? = null,
    @SerialName("top_words") val topWords: List<String> = emptyList(),
    @SerialName("emotion_distribution") val emotionDistribution: EmotionScoresDTO = EmotionScoresDTO(),
    @SerialName("dominant_emotion") val dominantEmotion: String = "neutral",
    val valence: String = "neutral",
    val confidence: Double = 0.0,
    @SerialName("model_backend") val modelBackend: String = "heuristic-v1"
)
