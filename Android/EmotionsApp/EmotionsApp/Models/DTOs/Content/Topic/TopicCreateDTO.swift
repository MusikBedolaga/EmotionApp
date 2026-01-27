//
//  TopicCreateDTO.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 09.11.2025.
//

import Foundation

struct TopicCreateDTO: Codable, Sendable {
    var name: String
    var description: String
    var color: String
}
