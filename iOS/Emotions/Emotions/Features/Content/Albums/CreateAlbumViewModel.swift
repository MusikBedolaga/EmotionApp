import Foundation

@MainActor
final class CreateAlbumViewModel: ObservableObject {
    private let maxDescriptionLength = 50
    private let userId: Int64
    private let albumsRepo: AlbumsRepositoryProtocol

    @Published var title: String = ""
    @Published var description: String = ""
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var titleValidationMessage: String?
    @Published var descriptionValidationMessage: String?

    init(userId: Int64, albumsRepo: AlbumsRepositoryProtocol) {
        self.userId = userId
        self.albumsRepo = albumsRepo
    }

    func save() async -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedTitle.isEmpty {
            titleValidationMessage = "Введите название"
        } else {
            titleValidationMessage = nil
        }

        if trimmedDescription.count > maxDescriptionLength {
            descriptionValidationMessage = "Описание должно быть не длиннее \(maxDescriptionLength) символов"
        } else {
            descriptionValidationMessage = nil
        }

        guard titleValidationMessage == nil, descriptionValidationMessage == nil else {
            return false
        }

        errorMessage = nil
        isSaving = true

        defer { isSaving = false }

        do {
            _ = try await albumsRepo.createAlbum(
                userId: userId,
                title: trimmedTitle,
                description: trimmedDescription.isEmpty ? nil : trimmedDescription
            )
            return true
        } catch {
            errorMessage = friendlyMessage(for: error)
            return false
        }
    }

    var descriptionCaption: String {
        "\(description.trimmingCharacters(in: .whitespacesAndNewlines).count)/\(maxDescriptionLength)"
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
                return "Проверьте данные альбома."
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

