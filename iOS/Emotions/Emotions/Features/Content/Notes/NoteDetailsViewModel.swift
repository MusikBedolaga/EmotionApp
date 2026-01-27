import Foundation

@MainActor
final class NoteDetailsViewModel: ObservableObject {
    private let userId: Int64
    private let noteId: Int64
    private let notesRepo: NotesRepositoryProtocol
    private let topicsRepo: TopicsRepositoryProtocol

    let albumTitle: String

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published private(set) var note: Note?
    @Published private(set) var topicName: String = "Все"

    init(
        userId: Int64,
        noteId: Int64,
        albumTitle: String,
        notesRepo: NotesRepositoryProtocol,
        topicsRepo: TopicsRepositoryProtocol
    ) {
        self.userId = userId
        self.noteId = noteId
        self.albumTitle = albumTitle
        self.notesRepo = notesRepo
        self.topicsRepo = topicsRepo
    }

    // Совместимость со старым вызовом (без albumTitle/topicsRepo).
    convenience init(
        userId: Int64,
        noteId: Int64,
        notesRepo: NotesRepositoryProtocol
    ) {
        self.init(
            userId: userId,
            noteId: noteId,
            albumTitle: "Альбом",
            notesRepo: notesRepo,
            topicsRepo: EmptyTopicsRepository()
        )
    }

    private struct EmptyTopicsRepository: TopicsRepositoryProtocol {
        func fetchTopics() async throws -> [Topic] { [] }
    }

    func load() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                let loadedNote = try await notesRepo.fetchNote(userId: userId, id: noteId)
                self.note = loadedNote

                let topics = (try? await topicsRepo.fetchTopics()) ?? []
                if let topicId = loadedNote.topicId,
                   let topic = topics.first(where: { $0.id == topicId }) {
                    self.topicName = topic.name
                } else {
                    self.topicName = "Все"
                }

                self.isLoading = false
            } catch {
                self.errorMessage = "Не удалось загрузить заметку"
                self.isLoading = false
            }
        }
    }

    func createdText(now: Date = Date()) -> String {
        guard let createdAt = note?.createdAt else { return "Создано —" }

        let calendar = Calendar.current
        let time = DateFormatters.dayMonthYearTime.string(from: createdAt).components(separatedBy: ", ").last ?? ""

        if calendar.isDateInToday(createdAt) {
            return "Создано сегодня, \(time)"
        }

        if calendar.isDateInYesterday(createdAt) {
            return "Создано вчера, \(time)"
        }

        // fallback: "Создано 21 апреля, 13:10"
        return "Создано \(DateFormatters.dayMonthYearTime.string(from: createdAt))"
    }
}

