import SwiftUI

struct AlbumDetailsView: View {
    @SwiftUI.Environment(\.container)
    private var container: AppContainer

    @StateObject
    private var viewModel: AlbumDetailsViewModel

    private let userId: EntityID
    private let albumId: EntityID

    init(userId: EntityID, albumId: EntityID, viewModel: AlbumDetailsViewModel) {
        self.userId = userId
        self.albumId = albumId
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("Альбом")
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
                Text("Пусто")
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

        case .loaded(let output):
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(output.album.title)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.TextPrimary)

                        if let description = output.album.description, !description.isEmpty {
                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(Color.TextSecondary)
                        }

                        Text(DateFormatters.dayMonthYear.string(from: output.album.createdAt))
                            .font(.caption)
                            .foregroundStyle(Color.TextSecondary)
                    }
                    .padding(.vertical, 6)
                }

                Section("Топики") {
                    if output.album.topics.isEmpty {
                        Text("Нет топиков")
                            .foregroundStyle(Color.TextSecondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(output.album.topics) { topic in
                                    TopicChipView(title: topic.name, colorHex: topic.colorHex)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }

                Section("Заметки") {
                    if output.notes.isEmpty {
                        Text("В этом альбоме пока нет заметок")
                            .foregroundStyle(Color.TextSecondary)
                    } else {
                        ForEach(output.notes) { note in
                            NavigationLink {
                                NoteDetailsView(
                                    userId: userId,
                                    noteId: note.id,
                                    viewModel: container.makeNoteDetailsViewModel(userId: userId, noteId: note.id)
                                )
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(note.title)
                                        .font(.headline)
                                        .foregroundStyle(Color.TextPrimary)
                                    Text(DateFormatters.dayMonthYearTime.string(from: note.createdAt))
                                        .font(.caption)
                                        .foregroundStyle(Color.TextSecondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.Background)
        }
    }
}

