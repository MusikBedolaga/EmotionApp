import Foundation

extension DefaultTopicsRepository {
    func fetchTopics() async throws -> [Topic] {
        try await getAllTopics()
    }
}

