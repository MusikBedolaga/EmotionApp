import Foundation

protocol AlbumsRepositoryProtocol {
    func fetchAlbums(userId: Int64) async throws -> [Album]
    func createAlbum(userId: Int64, title: String, description: String?) async throws -> Album
}

