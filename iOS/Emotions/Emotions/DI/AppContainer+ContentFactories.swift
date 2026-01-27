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

    @MainActor
    func makeAlbumsListViewModel(userId: EntityID) -> AlbumsListViewModel {
        AlbumsListViewModel(
            userId: userId,
            albumsRepo: MockAlbumsRepository(store: ContentMockStore.shared)
        )
    }

    @MainActor
    func makeAlbumDetailsViewModel(userId: EntityID, albumId: EntityID) -> AlbumDetailsViewModel {
        AlbumDetailsViewModel(
            userId: userId,
            albumId: albumId,
            albumsRepo: MockAlbumsRepository(store: ContentMockStore.shared),
            notesRepo: MockNotesRepository(store: ContentMockStore.shared),
            topicsRepo: MockTopicsRepository(store: ContentMockStore.shared)
        )
    }

    @MainActor
    func makeNoteDetailsViewModel(userId: EntityID, noteId: EntityID) -> NoteDetailsViewModel {
        NoteDetailsViewModel(
            userId: userId,
            noteId: noteId,
            albumTitle: "Альбом",
            notesRepo: MockNotesRepository(store: ContentMockStore.shared),
            topicsRepo: MockTopicsRepository(store: ContentMockStore.shared)
        )
    }
}

