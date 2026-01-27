import Foundation

@MainActor
final class AlbumDetailsViewModel: ObservableObject {
    struct AlbumDetails: Identifiable, Equatable {
        let id: EntityID
        let title: String
        let description: String?
        let createdAt: Date
        let topics: [Topic]
    }

    struct Output: Equatable {
        let album: AlbumDetails
        let notes: [Note]
    }

    enum State: Equatable {
        case idle
        case loading
        case empty
        case failed(String)
        case loaded(Output)
    }

    @Published private(set) var state: State = .idle

    private let userId: EntityID
    private let albumId: EntityID
    private let albumsRepo: AlbumsRepositoryProtocol
    private let notesRepo: NotesRepositoryProtocol
    private let topicsRepo: TopicsRepositoryProtocol

    init(
        userId: EntityID,
        albumId: EntityID,
        albumsRepo: AlbumsRepositoryProtocol,
        notesRepo: NotesRepositoryProtocol,
        topicsRepo: TopicsRepositoryProtocol
    ) {
        self.userId = userId
        self.albumId = albumId
        self.albumsRepo = albumsRepo
        self.notesRepo = notesRepo
        self.topicsRepo = topicsRepo
    }

    func load() async {
        state = .loading
        do {
            async let albumsTask = albumsRepo.fetchAlbums(userId: userId)
            async let notesTask = notesRepo.fetchNotes(userId: userId, albumId: albumId)
            async let topicsTask = topicsRepo.fetchTopics()

            let (albums, notes, allTopics) = try await (albumsTask, notesTask, topicsTask)

            guard let album = albums.first(where: { $0.id == albumId }) else {
                state = .empty
                return
            }

            let topicIds = Set(notes.compactMap(\.topicId))
            let usedTopics = allTopics.filter { topicIds.contains($0.id) }

            let details = AlbumDetails(
                id: album.id,
                title: album.title,
                description: album.description,
                createdAt: album.createdAt,
                topics: usedTopics
            )

            state = .loaded(Output(album: details, notes: notes))
        } catch {
            state = .failed("Не удалось загрузить альбом")
        }
    }
}

