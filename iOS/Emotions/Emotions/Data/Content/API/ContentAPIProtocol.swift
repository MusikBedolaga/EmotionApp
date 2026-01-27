import Foundation

protocol ContentAPIProtocol {
    func getNotesByAlbum(userId: EntityID, albumId: EntityID) async throws -> [NoteDTO]
    func getNote(userId: EntityID, id: EntityID) async throws -> NoteDTO
    func getAllTopics() async throws -> [TopicDTO]
}

