//
//  NoteShortDTO.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 09.11.2025.
//

import Foundation

struct NoteShortDTO: Codable, Sendable {
    var id: Int64
    var title: String
    var createdAt: Date
}
