import Foundation

@MainActor
final class CreateNoteViewModel: ObservableObject {
    private let userId: Int64
    private let notesRepo: NotesRepositoryProtocol
    private let albumsRepo: AlbumsRepositoryProtocol
    private let topicsRepo: TopicsRepositoryProtocol

    let initialAlbumId: Int64

    @Published var title: String = ""
    @Published var content: String = ""

    @Published var albums: [Album] = []
    @Published var topics: [Topic] = []

    @Published var selectedAlbumId: Int64
    @Published var selectedTopicId: Int64? = nil

    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    @Published var titleValidationMessage: String?
    @Published var contentValidationMessage: String?

    init(
        userId: Int64,
        initialAlbumId: Int64,
        notesRepo: NotesRepositoryProtocol,
        albumsRepo: AlbumsRepositoryProtocol,
        topicsRepo: TopicsRepositoryProtocol
    ) {
        self.userId = userId
        self.initialAlbumId = initialAlbumId
        self.notesRepo = notesRepo
        self.albumsRepo = albumsRepo
        self.topicsRepo = topicsRepo
        self.selectedAlbumId = initialAlbumId
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

                if !loadedAlbums.contains(where: { $0.id == self.selectedAlbumId }),
                   let first = loadedAlbums.first {
                    self.selectedAlbumId = first.id
                }

                self.isLoading = false
            } catch {
                self.errorMessage = "Не удалось загрузить данные"
                self.isLoading = false
            }
        }
    }

    func save() async -> Bool {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = content.trimmingCharacters(in: .whitespacesAndNewlines)

        var ok = true
        if t.isEmpty {
            titleValidationMessage = "Введите название"
            ok = false
        } else {
            titleValidationMessage = nil
        }

        if c.isEmpty {
            contentValidationMessage = "Введите содержимое"
            ok = false
        } else {
            contentValidationMessage = nil
        }

        guard ok else { return false }

        errorMessage = nil
        isSaving = true
        defer { isSaving = false }

        do {
            _ = try await notesRepo.createNote(
                userId: userId,
                albumId: selectedAlbumId,
                title: t,
                content: c,
                topicId: selectedTopicId
            )
            return true
        } catch {
            errorMessage = "Не удалось сохранить заметку"
            return false
        }
    }

    func albumTitle(for albumId: Int64) -> String {
        albums.first(where: { $0.id == albumId })?.title ?? "Альбом"
    }

    func topicTitle(for topicId: Int64?) -> String {
        guard let topicId else { return "Выбрать" }
        return topics.first(where: { $0.id == topicId })?.name ?? "Выбрать"
    }
}

