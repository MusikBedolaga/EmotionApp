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

    private lazy var contentAPI: ContentAPIProtocol = {
        ContentAPIClient(apiClient: apiClient)
    }()

    lazy var analyticsAIRepository: AnalyticsAIRepositoryProtocol = {
        AnalyticsAIRepository(apiClient: apiClient)
    }()

    // MARK: - Content repositories
    lazy var albumsRepository: AlbumsRepositoryProtocol = {
        DefaultAlbumsRepository(api: contentAPI)
    }()

    lazy var notesRepository: NotesRepositoryProtocol = {
        DefaultNotesRepository(api: contentAPI)
    }()

    lazy var topicsRepository: TopicsRepositoryProtocol = {
        DefaultTopicsRepository(api: contentAPI)
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
