//
//  Note.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 09.11.2025.
//

import Foundation

struct Note: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: Int64
    var title: String
    var content: String
    let createdAt: Date
    let albumID: Int64

    init(id: Int64,
         title: String,
         content: String,
         createdAt: Date = Date(),
         albumID: Int64) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.albumID = albumID
    }
}

