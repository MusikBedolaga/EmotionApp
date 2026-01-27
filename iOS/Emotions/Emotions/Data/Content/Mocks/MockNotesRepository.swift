import Foundation

final class MockNotesRepository: NotesRepositoryProtocol {
    private let store: ContentMockStore

    init(store: ContentMockStore = .shared) {
        self.store = store
    }

    func fetchNotes(userId: Int64, albumId: Int64) async throws -> [Note] {
        await mockDelay()
        return await store.fetchNotes(userId: userId, albumId: albumId)
    }

    func fetchNote(userId: Int64, id: Int64) async throws -> Note {
        await mockDelay()
        return await store.fetchNote(userId: userId, id: id)
    }

    func createNote(
        userId: Int64,
        albumId: Int64,
        title: String,
        content: String,
        topicId: Int64?
    ) async throws -> Note {
        await mockDelay()
        return await store.createNote(
            userId: userId,
            albumId: albumId,
            title: title,
            content: content,
            topicId: topicId
        )
    }

    private func mockDelay() async {
        let ms = UInt64(Int.random(in: 250...400))
        try? await Task.sleep(nanoseconds: ms * 1_000_000)
    }
}

