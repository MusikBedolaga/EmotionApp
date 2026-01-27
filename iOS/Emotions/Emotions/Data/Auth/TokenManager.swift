import Foundation

protocol TokenManagerProtocol {
    func ensureToken() async -> String?
    func save(token: String) async
    func reauthorize() async -> Bool
    func clearCredentials() async
}

actor TokenManager {
    private var token: String?
    private let credentialsStore: CredentialsStore
    private let tokenStore: TokenStore
    
    typealias APIClientFactory = () -> APIClientProtocol
    private let apiClientFactory: APIClientFactory

    init(credentialsStore: CredentialsStore, tokenStore: TokenStore, apiClientFactory: @escaping APIClientFactory) {
        self.credentialsStore = credentialsStore
        self.tokenStore = tokenStore
        self.apiClientFactory = apiClientFactory

    }
    
    @TaskLocal
    private static var _apiClient: APIClientProtocol = DummyAPIClient()
}

private struct DummyAPIClient: APIClientProtocol {
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        fatalError("DummyAPIClient should not be used for actual requests")
    }
    
    func request(endpoint: Endpoint) async throws {
        fatalError("DummyAPIClient should not be used for actual requests")
    }
}

// MARK: - TokenManagerProtocol
extension TokenManager: TokenManagerProtocol {
    func ensureToken() async -> String? {
        if let token = self.token {
            return token
        }
        if let storedToken = try? tokenStore.getToken() {
            self.token = storedToken
            return storedToken
        }
        return nil
    }

    func save(token: String) async {
        self.token = token
        try? tokenStore.save(token: token)
    }

    func reauthorize() async -> Bool {
        guard let (username, password) = try? credentialsStore.getCredentials() else {
            return false
        }

        let signInRequest = SignInRequestDTO(username: username, password: password)
        let signInEndpoint = AuthAPI.signIn(request: signInRequest)

        do {
            let authResponse: AuthResponseDTO = try await apiClientFactory().request(endpoint: signInEndpoint)
            self.token = authResponse.token
            try tokenStore.save(token: authResponse.token)
            return true
        } catch {
            self.token = nil
            try? tokenStore.clearToken()
            return false
        }
    }

    func clearCredentials() async {
        self.token = nil
        try? credentialsStore.clearCredentials()
        try? tokenStore.clearToken()
    }
}
