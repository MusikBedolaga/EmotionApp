import Foundation

final class DefaultNotesRepository: NotesRepositoryProtocol {
    private let api: ContentAPIProtocol

    init(api: ContentAPIProtocol) {
        self.api = api
    }

    func getNotesByAlbum(userId: EntityID, albumId: EntityID) async throws -> [NoteSummary] {
        let dtos = try await api.getNotesByAlbum(userId: userId, albumId: albumId)
        return dtos.map { dto in
            NoteSummary(id: dto.id, title: dto.title, createdAt: dto.createdAt)
        }
    }

    func getNote(userId: EntityID, id: EntityID) async throws -> Note {
        let dto = try await api.getNote(userId: userId, id: id)
        return dto.toDomain()
    }
}

