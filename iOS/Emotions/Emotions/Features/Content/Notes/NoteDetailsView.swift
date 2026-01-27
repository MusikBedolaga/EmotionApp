import SwiftUI

struct NoteDetailsView: View {
    @StateObject private var viewModel: NoteDetailsViewModel
    @State private var showEditAlert: Bool = false

    init(
        userId: Int64,
        noteId: Int64,
        albumTitle: String,
        notesRepo: NotesRepositoryProtocol,
        topicsRepo: TopicsRepositoryProtocol
    ) {
        _viewModel = StateObject(
            wrappedValue: NoteDetailsViewModel(
                userId: userId,
                noteId: noteId,
                albumTitle: albumTitle,
                notesRepo: notesRepo,
                topicsRepo: topicsRepo
            )
        )
    }

    // Legacy init (используется в старых Presentation-экранах).
    init(userId: EntityID, noteId: EntityID, viewModel: NoteDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    topCard
                    infoCard
                    bottomButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Заметка")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.load()
        }
        .alert("Редактирование недоступно", isPresented: $showEditAlert) {
            Button("Ок", role: .cancel) {}
        } message: {
            Text("Заметку можно только просматривать.")
        }
        .overlay {
            if viewModel.isLoading && viewModel.note == nil {
                ProgressView()
            }
        }
    }

    private var topCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Text(viewModel.note?.title ?? "—")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    showEditAlert = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.blue)
                        .frame(width: 34, height: 34)
                        .background(Color.blue.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            Text(viewModel.note?.content ?? "")
                .font(.body)
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            infoRow(text: viewModel.createdText())
            Divider()
            infoRow(text: "Альбом \(viewModel.albumTitle)")
            Divider()
            infoRow(text: "Топик \(viewModel.topicName)")
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }

    private func infoRow(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(Color.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
    }

    private var bottomButton: some View {
        Button {} label: {
            Text("Текст")
                .font(.headline)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.red.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

