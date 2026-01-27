import SwiftUI

struct AlbumsListView: View {
    @SwiftUI.Environment(\.container)
    private var container: AppContainer

    @StateObject
    private var viewModel: AlbumsListViewModel

    private let userId: EntityID

    init(userId: EntityID, viewModel: AlbumsListViewModel) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("Заметки")
            .task {
                await viewModel.load()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.Background)

        case .empty:
            VStack(spacing: 12) {
                Text("Пока нет альбомов")
                    .font(.headline)
                Button("Повторить") {
                    Task { await viewModel.load() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.Background)

        case .failed(let message):
            VStack(spacing: 12) {
                Text(message)
                    .font(.headline)
                Button("Повторить") {
                    Task { await viewModel.load() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.Background)

        case .loaded(let albums):
            List {
                ForEach(albums) { album in
                    NavigationLink {
                        AlbumDetailsView(
                            userId: userId,
                            albumId: album.id,
                            viewModel: container.makeAlbumDetailsViewModel(userId: userId, albumId: album.id)
                        )
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(album.title)
                                .font(.headline)
                                .foregroundStyle(Color.TextPrimary)

                            if let description = album.description, !description.isEmpty {
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.TextSecondary)
                                    .lineLimit(2)
                            }

                            Text(DateFormatters.dayMonthYear.string(from: album.createdAt))
                                .font(.caption)
                                .foregroundStyle(Color.TextSecondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.Background)
        }
    }
}

