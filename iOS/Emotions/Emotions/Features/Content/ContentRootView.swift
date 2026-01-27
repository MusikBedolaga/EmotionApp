import SwiftUI

struct ContentRootView: View {
    private let userId: Int64
    private let albumsRepo: AlbumsRepositoryProtocol
    private let notesRepo: NotesRepositoryProtocol
    private let topicsRepo: TopicsRepositoryProtocol

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

    var body: some View {
        NotesHomeView(
            userId: userId,
            albumsRepo: albumsRepo,
            notesRepo: notesRepo,
            topicsRepo: topicsRepo
        )
    }
}
