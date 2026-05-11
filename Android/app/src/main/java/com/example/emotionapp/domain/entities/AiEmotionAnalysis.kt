package com.example.emotionapp.domain.entities

data class EmotionScores(
    val joy: Double,
    val sadness: Double,
    val anger: Double,
    val fear: Double,
    val surprise: Double,
    val neutral: Double
)

data class EmotionCounts(
    val joy: Int,
    val sadness: Int,
    val anger: Int,
    val fear: Int,
    val surprise: Int,
    val neutral: Int
)

data class AlbumEmotionAnalysis(
    val albumId: Long,
    val summary: String?,
    val topWords: List<String>,
    val emotionDistribution: EmotionScores,
    val dominantEmotion: String,
    val valence: String,
    val confidence: Double,
    val noteEmotionCounts: EmotionCounts,
    val modelBackend: String
)

data class TopicEmotionAnalysis(
    val topicId: Long,
    val name: String,
    val color: String,
    val noteCount: Int,
    val summary: String?,
    val topWords: List<String>,
    val emotionDistribution: EmotionScores,
    val dominantEmotion: String,
    val valence: String,
    val confidence: Double,
    val modelBackend: String
)
