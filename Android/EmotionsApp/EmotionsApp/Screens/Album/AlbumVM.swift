//
//  AlbumVM.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 20.11.2025.
//

import Foundation

@MainActor
class AlbumViewModel: ObservableObject {
    @Published var albums: [Album] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: AlbumService

    init(service: AlbumService) {
        self.service = service
    }

    func loadAlbums() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await service.getAllAlbums()
            self.albums = result
        } catch {
            errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func deleteAlbum(id: Int64) async {
        do {
            try await service.deleteAlbum(id: id)
            await loadAlbums()
        } catch {
            errorMessage = "Ошибка удаления: \(error.localizedDescription)"
        }
    }

    func createAlbum(title: String, description: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let created = try await service.createAlbum(title: title, description: description)
            albums.append(created)
        } catch {
            errorMessage = "Ошибка создания: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func updateAlbum(_ album: Album) async {
        isLoading = true
        errorMessage = nil
        do {
            let updated = try await service.updateAlbum(album: album)
            if let index = albums.firstIndex(where: { $0.id == updated.id }) {
                albums[index] = updated
            }
        } catch {
            errorMessage = "Ошибка изменения: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
