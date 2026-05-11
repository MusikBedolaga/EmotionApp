import Foundation

final class DefaultNotesRepository: NotesRepositoryProtocol {
    private let api: ContentAPIProtocol

    init(api: ContentAPIProtocol) {
        self.api = api
    }

    func getNotesByAlbum(userId: EntityID, albumId: EntityID) async throws -> [NoteSummary] {
        let dtos = try await api.getNotesByAlbum(userId: userId, albumId: albumId)
        return dtos.map { $0.toSummary() }
    }

    func getNote(userId: EntityID, id: EntityID) async throws -> Note {
        let dto = try await api.getNote(userId: userId, id: id)
        return dto.toDomain()
    }

    func addNote(
        userId: EntityID,
        albumId: EntityID,
        title: String,
        content: String,
        topicId: EntityID?
    ) async throws -> Note {
        let dto = try await api.createNote(
            userId: userId,
            albumId: albumId,
            title: title,
            content: content,
            topicId: topicId
        )
        return dto.toDomain()
    }
}

