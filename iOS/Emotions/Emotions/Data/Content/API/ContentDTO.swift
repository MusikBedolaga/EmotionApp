import Foundation

struct AlbumDTO: Decodable, Equatable {
    let id: EntityID
    let title: String
    let description: String?
    let createdAt: Date
}

struct NoteDTO: Decodable, Equatable {
    let id: EntityID
    let albumId: EntityID
    let title: String
    let content: String
    let createdAt: Date
    let topicId: EntityID?
}

struct NoteSummaryDTO: Decodable, Equatable {
    let id: EntityID
    let title: String
    let createdAt: Date
}

struct TopicDTO: Decodable, Equatable {
    let id: EntityID
    let name: String
    let colorHex: String

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case colorHex = "color"
    }
}

struct CreateAlbumRequestDTO: Encodable, Equatable {
    let title: String
    let description: String?
}

struct CreateNoteRequestDTO: Encodable, Equatable {
    let albumId: EntityID
    let title: String
    let content: String
    let topicId: EntityID?
}

extension AlbumDTO {
    func toDomain(userId: EntityID) -> Album {
        Album(
            id: id,
            userId: userId,
            title: title,
            description: description,
            createdAt: createdAt
        )
    }
}

extension NoteDTO {
    func toDomain() -> Note {
        Note(
            id: id,
            albumId: albumId,
            title: title,
            content: content,
            createdAt: createdAt,
            topicId: topicId
        )
    }

    func toSummary() -> NoteSummary {
        NoteSummary(id: id, title: title, createdAt: createdAt)
    }
}

extension NoteSummaryDTO {
    func toSummary() -> NoteSummary {
        NoteSummary(id: id, title: title, createdAt: createdAt)
    }
}

extension TopicDTO {
    func toDomain() -> Topic {
        Topic(id: id, name: name, colorHex: colorHex, createdAt: Date())
    }
}

// Minimal model used by legacy repository/VM.
struct NoteSummary: Identifiable, Equatable {
    let id: EntityID
    let title: String
    let createdAt: Date
}

