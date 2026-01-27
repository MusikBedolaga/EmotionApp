//
//  Topic+Mapper.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 16.11.2025.
//

import Foundation

extension Topic {
    init(from dto: TopicShortDTO) {
        self.id = dto.id
        self.name = dto.name
        self.color = dto.color
        self.createdAt = Date()
    }
}

extension Topic {
    init(from dto: TopicResponseDTO) {
        self.id = dto.id
        self.name = dto.name
        self.color = dto.color
        self.createdAt = Date()
    }
}

extension Topic {
    var createDTO: TopicCreateDTO {
        TopicCreateDTO(
            name: self.name,
            description: "",
            color: self.color
        )
    }
}
