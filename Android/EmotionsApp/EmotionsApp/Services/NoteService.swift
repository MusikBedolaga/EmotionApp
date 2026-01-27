//
//  NoteService.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 16.11.2025.
//

import Foundation

protocol NoteService: Sendable {
    func createNote(newNote: Note) async throws -> Note
    func getNote(id: Int64) async throws -> Note
    func getAllNotes(albumId: Int64) async throws -> [Note]
    func deleteNote(id: Int64) async throws
}


final class NotServerImpl: NoteService, @unchecked Sendable {
    private var client: NoteClient
    
    init(client: NoteClient) {
        self.client = client
    }
    
    func createNote(newNote: Note) async throws -> Note {
        let response = try await client.createNote(newNote.createDTO)
        return Note(from: response)
    }
    
    func getNote(id: Int64) async throws -> Note {
        let response = try await client.getNote(id)
        return Note(from: response)
    }
    
    func getAllNotes(albumId: Int64) async throws -> [Note] {
        let dtos = try await client.getAllNotes(album: albumId)
        return dtos.map(Note.init(from:))
    }
    
    func deleteNote(id: Int64) async throws {
        try await client.deleteNote(id)
    }
}
