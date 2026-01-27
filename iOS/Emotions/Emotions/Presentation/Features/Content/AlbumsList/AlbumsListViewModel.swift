import Foundation

@MainActor
final class AlbumsListViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case empty
        case failed(String)
        case loaded([Album])
    }

    @Published private(set) var state: State = .idle

    private let userId: EntityID
    private let albumsRepo: AlbumsRepositoryProtocol

    init(userId: EntityID, albumsRepo: AlbumsRepositoryProtocol) {
        self.userId = userId
        self.albumsRepo = albumsRepo
    }

    func load() async {
        state = .loading
        do {
            let albums = try await albumsRepo.fetchAlbums(userId: userId)
            state = albums.isEmpty ? .empty : .loaded(albums)
        } catch {
            state = .failed("Не удалось загрузить альбомы")
        }
    }
}

