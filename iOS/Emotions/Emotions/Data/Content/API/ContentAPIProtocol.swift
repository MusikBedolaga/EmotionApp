import Foundation

protocol ContentAPIProtocol {
    func getAlbums(userId: EntityID) async throws -> [AlbumDTO]
    func createAlbum(userId: EntityID, title: String, description: String?) async throws -> AlbumDTO
    func getNotesByAlbum(userId: EntityID, albumId: EntityID) async throws -> [NoteSummaryDTO]
    func getNote(userId: EntityID, id: EntityID) async throws -> NoteDTO
    func createNote(
        userId: EntityID,
        albumId: EntityID,
        title: String,
        content: String,
        topicId: EntityID?
    ) async throws -> NoteDTO
    func getAllTopics() async throws -> [TopicDTO]
}

