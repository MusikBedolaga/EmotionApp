import Foundation

struct Note: Identifiable, Equatable {
    let id: Int64
    let albumId: Int64
    let title: String
    let content: String
    let createdAt: Date
    let topicId: Int64?
}

