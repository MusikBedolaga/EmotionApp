import Foundation

@MainActor
final class CreateNoteViewModel: ObservableObject {
    private let userId: Int64
    private let notesRepo: NotesRepositoryProtocol
    private let albumsRepo: AlbumsRepositoryProtocol
    private let topicsRepo: TopicsRepositoryProtocol

    let initialAlbumId: Int64

    @Published var title: String = ""
    @Published var content: String = ""

    @Published var albums: [Album] = []
    @Published var topics: [Topic] = []

    @Published var selectedAlbumId: Int64
    @Published var selectedTopicId: Int64? = nil

    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    @Published var titleValidationMessage: String?
    @Published var contentValidationMessage: String?

    init(
        userId: Int64,
        initialAlbumId: Int64,
        notesRepo: NotesRepositoryProtocol,
        albumsRepo: AlbumsRepositoryProtocol,
        topicsRepo: TopicsRepositoryProtocol
    ) {
        self.userId = userId
        self.initialAlbumId = initialAlbumId
        self.notesRepo = notesRepo
        self.albumsRepo = albumsRepo
        self.topicsRepo = topicsRepo
        self.selectedAlbumId = initialAlbumId
    }

    func load() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                async let albumsTask = albumsRepo.fetchAlbums(userId: userId)
                async let topicsTask = topicsRepo.fetchTopics()

                let (loadedAlbums, loadedTopics) = try await (albumsTask, topicsTask)
                self.albums = loadedAlbums
                self.topics = loadedTopics

                if let first = loadedAlbums.first,
                   !loadedAlbums.contains(where: { $0.id == self.selectedAlbumId }) {
                    self.selectedAlbumId = first.id
                }

                if loadedAlbums.isEmpty {
                    self.errorMessage = "Сначала создайте альбом, потом можно сохранить заметку"
                }

                self.isLoading = false
            } catch {
                self.errorMessage = "Не удалось загрузить данные"
                self.isLoading = false
            }
        }
    }

    func save() async -> Bool {
        guard !isLoading else {
            errorMessage = "Дождитесь загрузки альбомов"
            return false
        }

        guard !albums.isEmpty else {
            errorMessage = "Сначала создайте альбом, потом можно сохранить заметку"
            return false
        }

        if !albums.contains(where: { $0.id == selectedAlbumId }), let first = albums.first {
            selectedAlbumId = first.id
        }

        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = content.trimmingCharacters(in: .whitespacesAndNewlines)

        var ok = true
        if t.isEmpty {
            titleValidationMessage = "Введите название"
            ok = false
        } else {
            titleValidationMessage = nil
        }

        if c.isEmpty {
            contentValidationMessage = "Введите содержимое"
            ok = false
        } else {
            contentValidationMessage = nil
        }

        guard ok else { return false }

        errorMessage = nil
        isSaving = true
        defer { isSaving = false }

        do {
            _ = try await notesRepo.createNote(
                userId: userId,
                albumId: selectedAlbumId,
                title: t,
                content: c,
                topicId: selectedTopicId
            )
            return true
        } catch {
            errorMessage = friendlyMessage(for: error)
            return false
        }
    }

    var saveDisabled: Bool {
        isSaving || isLoading || albums.isEmpty
    }

    func albumTitle(for albumId: Int64) -> String {
        albums.first(where: { $0.id == albumId })?.title ?? "Альбом"
    }

    func topicTitle(for topicId: Int64?) -> String {
        guard let topicId else { return "Выбрать" }
        return topics.first(where: { $0.id == topicId })?.name ?? "Выбрать"
    }

    private func friendlyMessage(for error: Error) -> String {
        if let networkError = error as? NetworkError {
            return friendlyMessage(for: networkError)
        }

        let nsError = error as NSError
        if isConnectivityError(nsError) {
            return "Нет подключения к интернету. Попробуйте позже."
        }

        return error.localizedDescription
    }

    private func friendlyMessage(for error: NetworkError) -> String {
        switch error {
        case .requestFailed(let statusCode, let data):
            if let backendMessage = backendMessage(from: data) {
                return backendMessage
            }
            if statusCode == 400 {
                return "Проверьте данные заметки."
            }
            return "Ошибка сервера (\(statusCode)). Попробуйте позже."
        case .unauthorized:
            return "Сессия истекла. Войдите снова."
        case .invalidURL:
            return "Некорректный адрес сервера."
        case .decodingFailed:
            return "Сервер вернул неожиданный ответ."
        case .encodingFailed:
            return "Не удалось подготовить запрос."
        case .noCredentials:
            return "Не найдены данные для входа."
        case .unknown(let wrappedError):
            let nsError = wrappedError as NSError
            if isConnectivityError(nsError) {
                return "Нет подключения к интернету. Попробуйте позже."
            }
            return wrappedError.localizedDescription
        }
    }

    private func backendMessage(from data: Data?) -> String? {
        guard
            let data,
            !data.isEmpty,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return nil
        }

        if let message = json["message"] as? String, !message.isEmpty {
            return message
        }

        if let error = json["error"] as? String, !error.isEmpty {
            return error
        }

        return nil
    }

    private func isConnectivityError(_ error: NSError) -> Bool {
        guard error.domain == NSURLErrorDomain else {
            return false
        }

        switch error.code {
        case NSURLErrorNotConnectedToInternet,
             NSURLErrorTimedOut,
             NSURLErrorCannotFindHost,
             NSURLErrorCannotConnectToHost,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorDNSLookupFailed:
            return true
        default:
            return false
        }
    }
}

