//
//  NoteListViewModel.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 21.11.2025.
//

import SwiftUI

@MainActor
class NoteListViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: NoteService
    let albumId: Int64
    let albumTitle: String

    init(albumId: Int64, albumTitle: String, service: NoteService) {
        self.albumId = albumId
        self.albumTitle = albumTitle
        self.service = service
    }

    func loadNotes() async {
        isLoading = true
        errorMessage = nil
        do {
            notes = try await service.getAllNotes(albumId: albumId)
        } catch {
            errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func createNote(title: String, content: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let draft = Note(id: 0, title: title, content: content, albumID: albumId)
            let created = try await service.createNote(newNote: draft)
            notes.append(created)
        } catch {
            errorMessage = "Ошибка создания: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func deleteNote(id: Int64) async {
        do {
            try await service.deleteNote(id: id)
            notes.removeAll { $0.id == id }
        } catch {
            errorMessage = "Ошибка удаления: \(error.localizedDescription)"
        }
    }
}
