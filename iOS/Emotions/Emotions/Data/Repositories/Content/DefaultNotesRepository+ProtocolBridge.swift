import Foundation

extension DefaultNotesRepository {
    // Legacy API used inside this repo already.
    // These methods adapt the existing implementation to the new app-wide protocol.
    func fetchNotes(userId: Int64, albumId: Int64) async throws -> [Note] {
        let summaries = try await getNotesByAlbum(userId: userId, albumId: albumId)
        return summaries.map {
            Note(
                id: $0.id,
                albumId: albumId,
                title: $0.title,
                content: "",
                createdAt: $0.createdAt,
                topicId: nil
            )
        }
    }

    func fetchNote(userId: Int64, id: Int64) async throws -> Note {
        try await getNote(userId: userId, id: id)
    }

    func createNote(
        userId: Int64,
        albumId: Int64,
        title: String,
        content: String,
        topicId: Int64?
    ) async throws -> Note {
        // API/экран создания заметки ещё не реализованы в legacy-слое.
        // Возвращаем локальную модель без креша; позже заменим на реальный вызов API.
        return Note(
            id: 0,
            albumId: albumId,
            title: title,
            content: content,
            createdAt: Date(),
            topicId: topicId
        )
    }
}

