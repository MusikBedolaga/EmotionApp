//
//  Topic.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 09.11.2025.
//

import Foundation

struct Topic: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: Int64
    var name: String
    var color: String
    let createdAt: Date
    
    init(
        id: Int64,
        name: String,
        color: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.createdAt = createdAt
    }
}
