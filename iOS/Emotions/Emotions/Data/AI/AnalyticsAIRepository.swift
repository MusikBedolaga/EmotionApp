import Foundation

protocol AnalyticsAIRepositoryProtocol {
    func analyzeAlbumPeriod(
        userId: Int64,
        albumId: Int64,
        periodFrom: Date,
        periodTo: Date,
        periodType: String
    ) async throws -> AlbumEmotionAnalysis

    func getTopicEmotion(
        userId: Int64,
        topicId: Int64,
        periodFrom: Date,
        periodTo: Date
    ) async throws -> TopicEmotionAnalysis
}

final class AnalyticsAIRepository: AnalyticsAIRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func analyzeAlbumPeriod(
        userId: Int64,
        albumId: Int64,
        periodFrom: Date,
        periodTo: Date,
        periodType: String
    ) async throws -> AlbumEmotionAnalysis {
        let response: AlbumEmotionAnalysisResponseDTO = try await apiClient.request(
            endpoint: AnalyticsAIEndpoint.analyzeAlbumPeriod(
                userId: userId,
                albumId: albumId,
                request: AnalyzePeriodRequestDTO(
                    periodFrom: Self.isoFormatter.string(from: periodFrom),
                    periodTo: Self.isoFormatter.string(from: periodTo),
                    periodType: periodType,
                    analysisType: "emotion_period_report",
                    model: "emotion-zero-shot-v1"
                )
            )
        )
        return response.toDomain()
    }

    func getTopicEmotion(
        userId: Int64,
        topicId: Int64,
        periodFrom: Date,
        periodTo: Date
    ) async throws -> TopicEmotionAnalysis {
        let response: TopicEmotionAnalysisResponseDTO = try await apiClient.request(
            endpoint: AnalyticsAIEndpoint.topicEmotion(
                userId: userId,
                topicId: topicId,
                from: Self.isoFormatter.string(from: periodFrom),
                to: Self.isoFormatter.string(from: periodTo),
                model: "emotion-zero-shot-v1"
            )
        )
        return response.toDomain()
    }
}

private extension AnalyticsAIRepository {
    static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

private enum AnalyticsAIEndpoint {
    case analyzeAlbumPeriod(userId: Int64, albumId: Int64, request: AnalyzePeriodRequestDTO)
    case topicEmotion(userId: Int64, topicId: Int64, from: String, to: String, model: String)
}

extension AnalyticsAIEndpoint: Endpoint {
    var baseURL: URL {
        #if targetEnvironment(simulator)
        URL(string: AppConstants.API.aiSimulatorBaseURL)!
        #else
        URL(string: AppConstants.API.aiDeviceBaseURL)!
        #endif
    }

    var path: String {
        switch self {
        case .analyzeAlbumPeriod(_, let albumId, _):
            return "api/ai/albums/\(albumId):analyze-period"
        case .topicEmotion(_, let topicId, let from, let to, let model):
            let query = [
                URLQueryItem(name: "from", value: from),
                URLQueryItem(name: "to", value: to),
                URLQueryItem(name: "model", value: model)
            ]
            var components = URLComponents()
            components.queryItems = query
            let suffix = components.percentEncodedQuery.map { "?\($0)" } ?? ""
            return "api/ai/topics/\(topicId)/emotion\(suffix)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .analyzeAlbumPeriod:
            return .post
        case .topicEmotion:
            return .get
        }
    }

    var headers: [String : String]? {
        switch self {
        case .analyzeAlbumPeriod(let userId, _, _), .topicEmotion(let userId, _, _, _, _):
            return ["X-User-Id": String(userId)]
        }
    }

    var body: Encodable? {
        switch self {
        case .analyzeAlbumPeriod(_, _, let request):
            return request
        case .topicEmotion:
            return nil
        }
    }
}
