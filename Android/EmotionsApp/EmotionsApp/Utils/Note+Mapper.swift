//
//  Note+Mapper.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 16.11.2025.
//

import Foundation

// MARK: - DTO -> Domain

extension Note {
    init(from dto: NoteResponseDTO) {
        self.id = dto.id
        self.albumID = dto.albumId
        self.title = dto.title
        self.content = dto.content
        self.createdAt = dto.createdAt
    }
}

extension Note {
    init(from dto: NoteShortDTO, albumID: Int64) {
        self.id = dto.id
        self.albumID = albumID
        self.title = dto.title
        self.content = ""
        self.createdAt = dto.createdAt
    }
}

// MARK: - Domain -> DTO

extension Note {
    var updateDTO: NoteUpdateDTO {
        NoteUpdateDTO(
            title: self.title,
            content: self.content
        )
    }
}

extension Note {
    var createDTO: NoteCreateDTO {
        NoteCreateDTO(
            albumId: self.albumID,
            title: self.title,
            content: self.content
        )
    }
}

