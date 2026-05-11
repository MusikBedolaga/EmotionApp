import Foundation

struct EmotionScoresDTO: Decodable, Equatable {
    let joy: Double
    let sadness: Double
    let anger: Double
    let fear: Double
    let surprise: Double
    let neutral: Double
}

struct EmotionCountsDTO: Decodable, Equatable {
    let joy: Int
    let sadness: Int
    let anger: Int
    let fear: Int
    let surprise: Int
    let neutral: Int
}

struct AnalyzePeriodRequestDTO: Encodable, Equatable {
    let periodFrom: String
    let periodTo: String
    let periodType: String
    let analysisType: String
    let model: String

    private enum CodingKeys: String, CodingKey {
        case periodFrom = "period_from"
        case periodTo = "period_to"
        case periodType = "period_type"
        case analysisType = "analysis_type"
        case model
    }
}

struct AlbumEmotionResultDTO: Decodable, Equatable {
    let summary: String?
    let topWords: [String]
    let emotionDistribution: EmotionScoresDTO
    let dominantEmotion: String
    let valence: String
    let confidence: Double
    let noteEmotionCounts: EmotionCountsDTO
    let modelBackend: String

    private enum CodingKeys: String, CodingKey {
        case summary
        case topWords = "top_words"
        case emotionDistribution = "emotion_distribution"
        case dominantEmotion = "dominant_emotion"
        case valence
        case confidence
        case noteEmotionCounts = "note_emotion_counts"
        case modelBackend = "model_backend"
    }
}

struct AlbumEmotionAnalysisResponseDTO: Decodable, Equatable {
    let id: Int64
    let albumId: Int64
    let result: AlbumEmotionResultDTO

    private enum CodingKeys: String, CodingKey {
        case id
        case albumId = "album_id"
        case result = "result_json"
    }
}

struct TopicEmotionAnalysisResponseDTO: Decodable, Equatable {
    let topicId: Int64
    let name: String
    let color: String
    let noteCount: Int
    let summary: String?
    let topWords: [String]
    let emotionDistribution: EmotionScoresDTO
    let dominantEmotion: String
    let valence: String
    let confidence: Double
    let modelBackend: String

    private enum CodingKeys: String, CodingKey {
        case topicId = "topic_id"
        case name
        case color
        case noteCount = "note_count"
        case summary
        case topWords = "top_words"
        case emotionDistribution = "emotion_distribution"
        case dominantEmotion = "dominant_emotion"
        case valence
        case confidence
        case modelBackend = "model_backend"
    }
}

struct AlbumEmotionAnalysis: Equatable {
    let albumId: Int64
    let summary: String?
    let topWords: [String]
    let emotionDistribution: EmotionScoresDTO
    let dominantEmotion: String
    let valence: String
    let confidence: Double
    let noteEmotionCounts: EmotionCountsDTO
    let modelBackend: String
}

struct TopicEmotionAnalysis: Equatable {
    let topicId: Int64
    let name: String
    let color: String
    let noteCount: Int
    let summary: String?
    let topWords: [String]
    let emotionDistribution: EmotionScoresDTO
    let dominantEmotion: String
    let valence: String
    let confidence: Double
    let modelBackend: String
}

extension AlbumEmotionAnalysisResponseDTO {
    func toDomain() -> AlbumEmotionAnalysis {
        AlbumEmotionAnalysis(
            albumId: albumId,
            summary: result.summary,
            topWords: result.topWords,
            emotionDistribution: result.emotionDistribution,
            dominantEmotion: result.dominantEmotion,
            valence: result.valence,
            confidence: result.confidence,
            noteEmotionCounts: result.noteEmotionCounts,
            modelBackend: result.modelBackend
        )
    }
}

extension TopicEmotionAnalysisResponseDTO {
    func toDomain() -> TopicEmotionAnalysis {
        TopicEmotionAnalysis(
            topicId: topicId,
            name: name,
            color: color,
            noteCount: noteCount,
            summary: summary,
            topWords: topWords,
            emotionDistribution: emotionDistribution,
            dominantEmotion: dominantEmotion,
            valence: valence,
            confidence: confidence,
            modelBackend: modelBackend
        )
    }
}
