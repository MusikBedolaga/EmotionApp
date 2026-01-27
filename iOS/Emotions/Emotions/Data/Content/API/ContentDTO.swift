import Foundation

struct NoteDTO: Decodable, Equatable {
    let id: EntityID
    let albumId: EntityID
    let title: String
    let content: String
    let createdAt: Date
    let topicId: EntityID?
}

struct TopicDTO: Decodable, Equatable {
    let id: EntityID
    let name: String
    let colorHex: String
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

