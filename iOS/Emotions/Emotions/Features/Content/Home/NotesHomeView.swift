import SwiftUI

struct NotesHomeView: View {
    let userId: Int64
    let albumsRepo: AlbumsRepositoryProtocol
    let notesRepo: NotesRepositoryProtocol
    let topicsRepo: TopicsRepositoryProtocol

    @StateObject private var viewModel: NotesHomeViewModel

    @State private var showAnalytics: Bool = false
    @State private var showCreateAlbum: Bool = false

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
        _viewModel = StateObject(
            wrappedValue: NotesHomeViewModel(
                userId: userId,
                albumsRepo: albumsRepo,
                notesRepo: notesRepo,
                topicsRepo: topicsRepo
            )
        )
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.systemGray6)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    analyticsCard

                    SearchBarView(placeholder: "Поиск по альбомам", text: $viewModel.searchText)

                    topicsChips

                    albumsGrid
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }

            FloatingAddButton {
                showCreateAlbum = true
            }
            .padding(.trailing, 22)
            .padding(.bottom, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showAnalytics) {
            AnalyticsStubView()
        }
        .navigationDestination(isPresented: $showCreateAlbum) {
            CreateAlbumView(userId: userId, albumsRepo: albumsRepo)
        }
        .onChange(of: showCreateAlbum) { _, isPresented in
            if !isPresented {
                viewModel.load()
            }
        }
        .onAppear {
            viewModel.load()
        }
        .overlay {
            if viewModel.isLoading && viewModel.albums.isEmpty {
                ProgressView()
                    .tint(Color(.systemBlue))
            }
        }
    }

    private var header: some View {
        Text("Заметки")
            .font(.system(size: 34, weight: .bold))
            .foregroundStyle(Color(.label))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 6)
    }

    private var analyticsCard: some View {
        Button {
            showAnalytics = true
        } label: {
            HStack(alignment: .top, spacing: 14) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.85))
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        Text("Аналитика от ИИ")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(.label))

                        Spacer()

                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color(.systemBlue).opacity(0.9))
                                .frame(width: 10, height: 10)
                            Circle()
                                .fill(Color(.systemBlue).opacity(0.9))
                                .frame(width: 10, height: 10)
                        }
                        .padding(.top, 4)
                    }

                    Divider()
                        .overlay(Color(.systemBlue).opacity(0.25))

                    Text("Активность за неделю")
                        .font(.subheadline)
                        .foregroundStyle(Color(.label))

                    HStack {
                        Spacer(minLength: 0)
                        Text("Посмотреть график")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Color(.systemBlue))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 5)
                        Spacer(minLength: 0)
                    }
                    .padding(.top, 2)
                }
            }
            .padding(16)
            .background(Color(.systemIndigo).opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var topicsChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ChipView(title: "Все", isSelected: viewModel.selectedTopicId == nil) {
                    viewModel.selectedTopicId = nil
                }

                ForEach(viewModel.topics) { topic in
                    ChipView(title: topic.name, isSelected: viewModel.selectedTopicId == topic.id) {
                        viewModel.selectedTopicId = topic.id
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var albumsGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]

        return LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
            ForEach(viewModel.filteredAlbums) { album in
                NavigationLink {
                    AlbumNotesListView(
                        userId: userId,
                        albumId: album.id,
                        albumTitle: album.title,
                        notesRepo: notesRepo,
                        albumsRepo: albumsRepo,
                        topicsRepo: topicsRepo
                    )
                } label: {
                    AlbumCardView(
                        title: album.title,
                        notesCountText: "\(viewModel.notesCount(for: album.id)) заметок"
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 6)
    }
}

