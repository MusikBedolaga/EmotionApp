import Foundation

final class DefaultAlbumsRepository: AlbumsRepositoryProtocol {
    private let api: ContentAPIProtocol

    init(api: ContentAPIProtocol) {
        self.api = api
    }

    func fetchAlbums(userId: Int64) async throws -> [Album] {
        try await api.getAlbums(userId: userId)
            .sorted { $0.createdAt < $1.createdAt }
            .map { $0.toDomain(userId: userId) }
    }

    func createAlbum(userId: Int64, title: String, description: String?) async throws -> Album {
        let dto = try await api.createAlbum(
            userId: userId,
            title: title,
            description: description
        )
        return dto.toDomain(userId: userId)
    }
}
