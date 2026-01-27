//
//  AlbumResponseDTO.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 09.11.2025.
//

import Foundation

struct AlbumResponseDTO: Codable, Sendable {
    var id: Int64
    var title: String
    var description: String
    var createdAt: Date
    var topics: [TopicShortDTO]
}
