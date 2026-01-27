import Foundation

final class DefaultTopicsRepository: TopicsRepositoryProtocol {
    private let api: ContentAPIProtocol

    init(api: ContentAPIProtocol) {
        self.api = api
    }

    func getAllTopics() async throws -> [Topic] {
        let dtos = try await api.getAllTopics()
        // В backend DTO нет createdAt, поэтому для доменной модели ставим Date() (пока только mock/read-only).
        return dtos
            .sorted { $0.id < $1.id }
            .map { $0.toDomain() }
    }
}

