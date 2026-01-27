import Foundation

protocol TopicsRepositoryProtocol {
    func fetchTopics() async throws -> [Topic]
}

