//
//  Album+Mapper.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 16.11.2025.
//

import Foundation

extension Album {
    init(from dto: AlbumResponseDTO) {
        self.id = dto.id
        self.title = dto.title
        self.description = dto.description
        self.createdAt = dto.createdAt
        self.topics = dto.topics.map { Topic(from: $0) }
    }
}

extension Album {
    var updateDTO: AlbumUpdateDTO {
        AlbumUpdateDTO(
            title: self.title,
            description: self.description
        )
    }
}

extension Album {
    init(from dto: AlbumShortDTO) {
        self.id = dto.id
        self.title = dto.title
        self.description = dto.description
        self.createdAt = Date()
        self.topics = []
    }
}
