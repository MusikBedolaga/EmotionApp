//
//  AlbumService.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 16.11.2025.
//

import Foundation

protocol AlbumService: Sendable {
    func getAlbum(id: Int64) async throws -> Album
    func getAllAlbums() async throws -> [Album]
    func createAlbum(title: String, description: String) async throws -> Album
    func updateAlbum(album: Album) async throws -> Album
    func deleteAlbum(id: Int64) async throws
}

final class AlbumServiceImpl: AlbumService, @unchecked Sendable {
    private let client: AlbumClient
    
    init(client: AlbumClient) {
        self.client = client
    }
    
    
    func getAlbum(id: Int64) async throws -> Album {
        let dto = try await client.getAlbum(id)
        return Album(from: dto)
    }
    
    func getAllAlbums() async throws -> [Album] {
        let dtos = try await client.getAllAlbums()
        return dtos.map(Album.init(from:))
    }
    
    func createAlbum(title: String, description: String) async throws -> Album {
        let request = AlbumCreateDTO(title: title, description: description)
        let dto = try await client.createAlbum(request)
        return Album(from: dto)
    }
    
    func updateAlbum(album: Album) async throws -> Album {
        let request = AlbumUpdateDTO(title: album.title, description: album.description)
        let dto = try await client.updateAlbum(album.id, request)
        return Album(from: dto)
    }
    
    func deleteAlbum(id: Int64) async throws {
        try await client.deleteAlbum(id)
    }
}
