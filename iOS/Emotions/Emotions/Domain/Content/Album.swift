import Foundation

struct Album: Identifiable, Equatable {
    let id: Int64
    let userId: Int64
    let title: String
    let description: String?
    let createdAt: Date
}

