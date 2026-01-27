import Foundation

struct Topic: Identifiable, Equatable {
    let id: Int64
    let name: String
    let colorHex: String
    let createdAt: Date
}

