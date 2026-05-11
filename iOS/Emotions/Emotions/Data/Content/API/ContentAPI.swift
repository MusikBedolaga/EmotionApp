import Foundation

final class ContentAPIClient: ContentAPIProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func getAlbums(userId: EntityID) async throws -> [AlbumDTO] {
        try await apiClient.request(endpoint: ContentAPI.allAlbums)
    }

    func createAlbum(userId: EntityID, title: String, description: String?) async throws -> AlbumDTO {
        try await apiClient.request(
            endpoint: ContentAPI.createAlbum(
                request: CreateAlbumRequestDTO(
                    title: title,
                    description: description
                )
            )
        )
    }

    func getNotesByAlbum(userId: EntityID, albumId: EntityID) async throws -> [NoteSummaryDTO] {
        try await apiClient.request(endpoint: ContentAPI.notesByAlbum(albumId: albumId))
    }

    func getNote(userId: EntityID, id: EntityID) async throws -> NoteDTO {
        try await apiClient.request(endpoint: ContentAPI.note(id: id))
    }

    func createNote(
        userId: EntityID,
        albumId: EntityID,
        title: String,
        content: String,
        topicId: EntityID?
    ) async throws -> NoteDTO {
        try await apiClient.request(
            endpoint: ContentAPI.createNote(
                request: CreateNoteRequestDTO(
                    albumId: albumId,
                    title: title,
                    content: content,
                    topicId: topicId
                )
            )
        )
    }

    func getAllTopics() async throws -> [TopicDTO] {
        try await apiClient.request(endpoint: ContentAPI.topics)
    }
}

private enum ContentAPI {
    case allAlbums
    case createAlbum(request: CreateAlbumRequestDTO)
    case notesByAlbum(albumId: EntityID)
    case note(id: EntityID)
    case createNote(request: CreateNoteRequestDTO)
    case topics
}

extension ContentAPI: Endpoint {
    var path: String {
        switch self {
        case .allAlbums:
            return "content/albums/all-albums"
        case .createAlbum:
            return "content/albums/create-album"
        case .notesByAlbum(let albumId):
            return "content/notes/album/\(albumId)"
        case .note(let id):
            return "content/notes/\(id)"
        case .createNote:
            return "content/notes/create-note"
        case .topics:
            return "content/topics"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .allAlbums, .notesByAlbum, .note, .topics:
            return .get
        case .createAlbum, .createNote:
            return .post
        }
    }

    var body: Encodable? {
        switch self {
        case .createAlbum(let request):
            return request
        case .createNote(let request):
            return request
        case .allAlbums, .notesByAlbum, .note, .topics:
            return nil
        }
    }
}
