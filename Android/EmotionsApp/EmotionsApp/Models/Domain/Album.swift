//
//  Album.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 09.11.2025.
//

import Foundation

struct Album: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: Int64
    var title: String
    var description: String
    let createdAt: Date
    var topics: [Topic] = []

    init(id: Int64,
         title: String,
         description: String,
         createdAt: Date = Date(),
         topics: [Topic] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.createdAt = createdAt
        self.topics = topics
    }
}
