import Foundation

extension AppContainer {
    // MARK: - Content (Notes) factories

    // MARK: - Repositories
    func makeAlbumsRepository() -> AlbumsRepositoryProtocol {
        albumsRepository
    }

    func makeNotesRepository() -> NotesRepositoryProtocol {
        notesRepository
    }

    func makeTopicsRepository() -> TopicsRepositoryProtocol {
        topicsRepository
    }

    func makeAnalyticsAIRepository() -> AnalyticsAIRepositoryProtocol {
        analyticsAIRepository
    }

    @MainActor
    func makeAlbumsListViewModel(userId: EntityID) -> AlbumsListViewModel {
        AlbumsListViewModel(
            userId: userId,
            albumsRepo: albumsRepository
        )
    }

    @MainActor
    func makeAlbumDetailsViewModel(userId: EntityID, albumId: EntityID) -> AlbumDetailsViewModel {
        AlbumDetailsViewModel(
            userId: userId,
            albumId: albumId,
            albumsRepo: albumsRepository,
            notesRepo: notesRepository,
            topicsRepo: topicsRepository
        )
    }

    @MainActor
    func makeNoteDetailsViewModel(userId: EntityID, noteId: EntityID) -> NoteDetailsViewModel {
        NoteDetailsViewModel(
            userId: userId,
            noteId: noteId,
            albumTitle: "Альбом",
            notesRepo: notesRepository,
            topicsRepo: topicsRepository
        )
    }
}

