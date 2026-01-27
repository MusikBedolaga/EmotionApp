import SwiftUI

struct CreateNoteView: View {
    @SwiftUI.Environment(\.dismiss)
    private var dismiss: DismissAction

    let userId: Int64
    let initialAlbumId: Int64
    let initialAlbumTitle: String
    let notesRepo: NotesRepositoryProtocol
    let albumsRepo: AlbumsRepositoryProtocol
    let topicsRepo: TopicsRepositoryProtocol

    @StateObject private var viewModel: CreateNoteViewModel

    init(
        userId: Int64,
        albumId: Int64,
        albumTitle: String,
        notesRepo: NotesRepositoryProtocol,
        albumsRepo: AlbumsRepositoryProtocol,
        topicsRepo: TopicsRepositoryProtocol
    ) {
        self.userId = userId
        self.initialAlbumId = albumId
        self.initialAlbumTitle = albumTitle
        self.notesRepo = notesRepo
        self.albumsRepo = albumsRepo
        self.topicsRepo = topicsRepo
        _viewModel = StateObject(
            wrappedValue: CreateNoteViewModel(
                userId: userId,
                initialAlbumId: albumId,
                notesRepo: notesRepo,
                albumsRepo: albumsRepo,
                topicsRepo: topicsRepo
            )
        )
    }

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    card

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(Color.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Text("Содержимое нельзя будет изменить позже")
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 6)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Новая заметка")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.load()
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Название
            VStack(alignment: .leading, spacing: 8) {
                Text("Название")
                    .font(.headline)

                TextField("Название", text: $viewModel.title)
                    .textFieldStyle(.roundedBorder)

                if let validation = viewModel.titleValidationMessage {
                    Text(validation)
                        .font(.footnote)
                        .foregroundStyle(Color.red)
                }
            }

            // Содержимое
            VStack(alignment: .leading, spacing: 8) {
                Text("Содержимое")
                    .font(.headline)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $viewModel.content)
                        .frame(minHeight: 140)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    if viewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Введите текст заметки...")
                            .foregroundStyle(Color.secondary.opacity(0.9))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                    }
                }

                if let validation = viewModel.contentValidationMessage {
                    Text(validation)
                        .font(.footnote)
                        .foregroundStyle(Color.red)
                }
            }

            // Альбом
            VStack(alignment: .leading, spacing: 8) {
                Text("Альбом")
                    .font(.headline)

                Picker(selection: $viewModel.selectedAlbumId) {
                    ForEach(viewModel.albums) { album in
                        Text(album.title).tag(album.id)
                    }
                } label: {
                    HStack {
                        Text(viewModel.albums.isEmpty ? initialAlbumTitle : viewModel.albumTitle(for: viewModel.selectedAlbumId))
                            .foregroundStyle(Color.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .pickerStyle(.menu)
            }

            // Топик
            VStack(alignment: .leading, spacing: 8) {
                Text("Топик")
                    .font(.headline)

                Picker(selection: Binding<Int64?>(
                    get: { viewModel.selectedTopicId },
                    set: { viewModel.selectedTopicId = $0 }
                )) {
                    Text("Выбрать").tag(Int64?.none)
                    ForEach(viewModel.topics) { topic in
                        Text(topic.name).tag(Int64?.some(topic.id))
                    }
                } label: {
                    HStack {
                        Text(viewModel.topicTitle(for: viewModel.selectedTopicId))
                            .foregroundStyle(Color.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .pickerStyle(.menu)
            }

            Button {
                Task {
                    let ok = await viewModel.save()
                    if ok {
                        dismiss()
                    }
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.blue)
                        .frame(height: 54)
                        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)

                    if viewModel.isSaving {
                        ProgressView()
                            .tint(Color.white)
                    } else {
                        Text("Сохранить")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSaving)
            .opacity(viewModel.isSaving ? 0.85 : 1.0)
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

