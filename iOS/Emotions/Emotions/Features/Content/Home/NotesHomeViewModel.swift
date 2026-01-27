import Foundation

@MainActor
final class NotesHomeViewModel: ObservableObject {
    private let userId: Int64
    private let albumsRepo: AlbumsRepositoryProtocol
    private let notesRepo: NotesRepositoryProtocol
    private let topicsRepo: TopicsRepositoryProtocol

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var albums: [Album] = []
    @Published var topics: [Topic] = []
    @Published var searchText: String = ""
    @Published var selectedTopicId: Int64? = nil // nil = "Все"

    // Вспомогательное для UI (не обязательно по требованиям, но нужно для "N заметок" и фильтра по топику)
    @Published private(set) var albumNoteCounts: [Int64: Int] = [:]
    private var albumTopicIds: [Int64: Set<Int64>] = [:]

    init(
        userId: Int64,
        albumsRepo: AlbumsRepositoryProtocol,
        notesRepo: NotesRepositoryProtocol,
        topicsRepo: TopicsRepositoryProtocol
    ) {
        self.userId = userId
        self.albumsRepo = albumsRepo
        self.notesRepo = notesRepo
        self.topicsRepo = topicsRepo
    }

    func load() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                async let albumsTask = albumsRepo.fetchAlbums(userId: userId)
                async let topicsTask = topicsRepo.fetchTopics()

                let (loadedAlbums, loadedTopics) = try await (albumsTask, topicsTask)
                self.albums = loadedAlbums
                self.topics = loadedTopics

                await self.loadAlbumMeta(albums: loadedAlbums)
                self.isLoading = false
            } catch {
                self.errorMessage = "Не удалось загрузить данные"
                self.isLoading = false
            }
        }
    }

    var filteredAlbums: [Album] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return albums.filter { album in
            let matchesSearch: Bool
            if q.isEmpty {
                matchesSearch = true
            } else {
                matchesSearch = album.title.lowercased().contains(q)
            }

            let matchesTopic: Bool
            if let selectedTopicId {
                matchesTopic = (albumTopicIds[album.id]?.contains(selectedTopicId) ?? false)
            } else {
                matchesTopic = true
            }

            return matchesSearch && matchesTopic
        }
    }

    func notesCount(for albumId: Int64) -> Int {
        albumNoteCounts[albumId] ?? 0
    }

    private func loadAlbumMeta(albums: [Album]) async {
        var counts: [Int64: Int] = [:]
        var topicsByAlbum: [Int64: Set<Int64>] = [:]

        await withTaskGroup(of: (Int64, [Note]).self) { group in
            for album in albums {
                group.addTask { [userId, notesRepo] in
                    let notes = (try? await notesRepo.fetchNotes(userId: userId, albumId: album.id)) ?? []
                    return (album.id, notes)
                }
            }

            for await (albumId, notes) in group {
                counts[albumId] = notes.count
                let ids = Set(notes.compactMap(\.topicId))
                topicsByAlbum[albumId] = ids
            }
        }

        self.albumNoteCounts = counts
        self.albumTopicIds = topicsByAlbum
    }
}

