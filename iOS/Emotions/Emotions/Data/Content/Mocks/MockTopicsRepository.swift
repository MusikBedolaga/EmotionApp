import Foundation

final class MockTopicsRepository: TopicsRepositoryProtocol {
    private let store: ContentMockStore

    init(store: ContentMockStore = .shared) {
        self.store = store
    }

    func fetchTopics() async throws -> [Topic] {
        await mockDelay()
        return await store.fetchTopics()
    }

    private func mockDelay() async {
        let ms = UInt64(Int.random(in: 250...400))
        try? await Task.sleep(nanoseconds: ms * 1_000_000)
    }
}

