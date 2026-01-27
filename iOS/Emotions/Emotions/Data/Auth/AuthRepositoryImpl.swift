import Foundation

final class AuthRepository {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
}

// MARK: - AuthRepositoryProtocol
extension AuthRepository: AuthRepositoryProtocol {
    func signIn(request: SignInRequestDTO) async throws -> AuthResponseDTO {
        try await apiClient.request(endpoint: AuthAPI.signIn(request: request))
    }

    func signUp(request: SignUpRequestDTO) async throws -> AuthResponseDTO {
        try await apiClient.request(endpoint: AuthAPI.signUp(request: request))
    }
}
