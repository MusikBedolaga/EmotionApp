import Foundation
import SwiftUI

final class AppContainer {
    // MARK: - Singletons
    lazy var keychainStore: KeychainStore = {
        KeychainStore(service: "com.emotions.app")
    }()

    private lazy var apiClient: APIClientProtocol = {
        APIClient(tokenManager: tokenManager)
    }()

    lazy var tokenManager: TokenManagerProtocol = {
        TokenManager(
            credentialsStore: keychainStore,
            tokenStore: keychainStore,
            apiClientFactory: { [unowned self] in
                self.apiClient
            }
        )
    }()

    // MARK: - Repositories
    private lazy var authRepository: AuthRepositoryProtocol = {
        AuthRepository(apiClient: apiClient)
    }()

    // MARK: - Content repositories (Mocks)
    // Держим инстансы стабильными, чтобы SwiftUI не пересоздавал деревья при ререндере.
    lazy var albumsRepository: AlbumsRepositoryProtocol = {
        MockAlbumsRepository(store: ContentMockStore.shared)
    }()

    lazy var notesRepository: NotesRepositoryProtocol = {
        MockNotesRepository(store: ContentMockStore.shared)
    }()

    lazy var topicsRepository: TopicsRepositoryProtocol = {
        MockTopicsRepository(store: ContentMockStore.shared)
    }()

    // MARK: - Use Cases
    lazy var authUseCase: AuthUseCaseProtocol = {
        AuthUseCase(authRepository: authRepository)
    }()

    // MARK: - ViewModels Factories
    @MainActor
    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(authUseCase: authUseCase)
    }

    // MARK: - AppSession Factory
    @MainActor
    func makeAppSession() -> AppSession {
        AppSession(container: self, tokenManager: tokenManager)
    }
}

// MARK: - EnvironmentKey
struct AppContainerKey: EnvironmentKey {
    static let defaultValue: AppContainer = .init()
}

extension EnvironmentValues {
    var container: AppContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}
