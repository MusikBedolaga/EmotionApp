import Foundation

@MainActor
final class AlbumNotesListViewModel: ObservableObject {
    private let userId: Int64
    private let albumId: Int64
    private let notesRepo: NotesRepositoryProtocol

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var notes: [Note] = []
    @Published var searchText: String = ""

    init(userId: Int64, albumId: Int64, notesRepo: NotesRepositoryProtocol) {
        self.userId = userId
        self.albumId = albumId
        self.notesRepo = notesRepo
    }

    func load() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                let loaded = try await notesRepo.fetchNotes(userId: userId, albumId: albumId)
                self.notes = loaded
                self.isLoading = false
            } catch {
                self.errorMessage = "Не удалось загрузить заметки"
                self.isLoading = false
            }
        }
    }

    func retry() {
        load()
    }

    var filteredNotes: [Note] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return notes }

        return notes.filter { note in
            note.title.lowercased().contains(q) || note.content.lowercased().contains(q)
        }
    }
}

