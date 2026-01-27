import SwiftUI

struct AlbumNotesListView: View {
    let userId: Int64
    let albumId: Int64
    let albumTitle: String
    let notesRepo: NotesRepositoryProtocol
    let albumsRepo: AlbumsRepositoryProtocol
    let topicsRepo: TopicsRepositoryProtocol

    @StateObject private var viewModel: AlbumNotesListViewModel
    @State private var showCreateNote: Bool = false

    init(
        userId: Int64,
        albumId: Int64,
        albumTitle: String,
        notesRepo: NotesRepositoryProtocol,
        albumsRepo: AlbumsRepositoryProtocol,
        topicsRepo: TopicsRepositoryProtocol
    ) {
        self.userId = userId
        self.albumId = albumId
        self.albumTitle = albumTitle
        self.notesRepo = notesRepo
        self.albumsRepo = albumsRepo
        self.topicsRepo = topicsRepo
        _viewModel = StateObject(wrappedValue: AlbumNotesListViewModel(userId: userId, albumId: albumId, notesRepo: notesRepo))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.systemGray6)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SearchBarView(placeholder: "Поиск по заметкам", text: $viewModel.searchText)
                        .padding(.top, 6)

                    if let error = viewModel.errorMessage {
                        VStack(spacing: 10) {
                            Text(error)
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                            Button("Повторить") {
                                viewModel.retry()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                    }

                    VStack(spacing: 14) {
                        ForEach(viewModel.filteredNotes) { note in
                            NavigationLink {
                                NoteDetailsView(
                                    userId: userId,
                                    noteId: note.id,
                                    albumTitle: albumTitle,
                                    notesRepo: notesRepo,
                                    topicsRepo: topicsRepo
                                )
                            } label: {
                                NoteCardView(
                                    title: note.title,
                                    dateText: DateFormatters.dayMonthYearTime.string(from: note.createdAt)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }

            FloatingAddButton {
                showCreateNote = true
            }
            .padding(.trailing, 22)
            .padding(.bottom, 24)
        }
        .navigationTitle(albumTitle)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $showCreateNote) {
            CreateNoteView(
                userId: userId,
                albumId: albumId,
                albumTitle: albumTitle,
                notesRepo: notesRepo,
                albumsRepo: albumsRepo,
                topicsRepo: topicsRepo
            )
        }
        .onChange(of: showCreateNote) { _, isPresented in
            if !isPresented {
                viewModel.load()
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
}

private struct NoteCardView: View {
    let title: String
    let dateText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.primary)
                .lineLimit(2)

            Text(dateText)
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

