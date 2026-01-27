//
//  NoteResponseDTO.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 09.11.2025.
//

import Foundation

struct NoteResponseDTO: Codable, Sendable {
    var id: Int64
    var albumId: Int64
    var title: String
    var content: String
    var createdAt: Date
}
