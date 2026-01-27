import Foundation

protocol NotesRepositoryProtocol {
    func fetchNotes(userId: Int64, albumId: Int64) async throws -> [Note]
    func fetchNote(userId: Int64, id: Int64) async throws -> Note
    func createNote(
        userId: Int64,
        albumId: Int64,
        title: String,
        content: String,
        topicId: Int64?
    ) async throws -> Note
}

