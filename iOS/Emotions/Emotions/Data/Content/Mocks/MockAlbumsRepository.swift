import Foundation

final class MockAlbumsRepository: AlbumsRepositoryProtocol {
    private let store: ContentMockStore

    init(store: ContentMockStore = .shared) {
        self.store = store
    }

    func fetchAlbums(userId: Int64) async throws -> [Album] {
        await mockDelay()
        return await store.fetchAlbums(userId: userId)
    }

    func createAlbum(userId: Int64, title: String, description: String?) async throws -> Album {
        await mockDelay()
        return await store.createAlbum(userId: userId, title: title, description: description)
    }

    private func mockDelay() async {
        let ms = UInt64(Int.random(in: 250...400))
        try? await Task.sleep(nanoseconds: ms * 1_000_000)
    }
}

