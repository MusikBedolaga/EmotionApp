import Foundation

@MainActor
final class CreateAlbumViewModel: ObservableObject {
    private let userId: Int64
    private let albumsRepo: AlbumsRepositoryProtocol

    @Published var title: String = ""
    @Published var description: String = ""
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var titleValidationMessage: String?

    init(userId: Int64, albumsRepo: AlbumsRepositoryProtocol) {
        self.userId = userId
        self.albumsRepo = albumsRepo
    }

    func save() async -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            titleValidationMessage = "Введите название"
            return false
        }

        titleValidationMessage = nil
        errorMessage = nil
        isSaving = true

        defer { isSaving = false }

        do {
            let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
            _ = try await albumsRepo.createAlbum(
                userId: userId,
                title: trimmedTitle,
                description: trimmedDescription.isEmpty ? nil : trimmedDescription
            )
            return true
        } catch {
            errorMessage = "Не удалось сохранить альбом"
            return false
        }
    }
}

