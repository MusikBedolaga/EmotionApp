import Foundation

extension DefaultNotesRepository {
    func fetchNotes(userId: Int64, albumId: Int64) async throws -> [Note] {
        let summaries = try await getNotesByAlbum(userId: userId, albumId: albumId)

        return try await withThrowingTaskGroup(of: Note.self) { group in
            for summary in summaries {
                group.addTask { [weak self] in
                    guard let self else {
                        throw NetworkError.unknown(DefaultNotesRepositoryDeallocated())
                    }
                    return try await self.getNote(userId: userId, id: summary.id)
                }
            }

            var notes: [Note] = []
            for try await note in group {
                notes.append(note)
            }
            return notes.sorted { $0.createdAt < $1.createdAt }
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
        try await addNote(
            userId: userId,
            albumId: albumId,
            title: title,
            content: content,
            topicId: topicId
        )
    }
}

private struct DefaultNotesRepositoryDeallocated: LocalizedError {}

