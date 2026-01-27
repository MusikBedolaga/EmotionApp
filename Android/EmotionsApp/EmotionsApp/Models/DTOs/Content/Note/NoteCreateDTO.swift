//
//  NoteCreateDTO.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 09.11.2025.
//

import Foundation

struct NoteCreateDTO: Codable, Sendable {
    var albumId: Int64
    var title: String
    var content: String
}
