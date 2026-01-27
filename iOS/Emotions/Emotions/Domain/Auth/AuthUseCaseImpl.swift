import Foundation

protocol AuthUseCaseProtocol: AnyObject {
    func signIn(request: SignInRequestDTO) async throws -> AuthResponseDTO
    func signUp(request: SignUpRequestDTO) async throws -> AuthResponseDTO
}

final class AuthUseCase: AuthUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func signIn(request: SignInRequestDTO) async throws -> AuthResponseDTO {
        try await authRepository.signIn(request: request)
    }

    func signUp(request: SignUpRequestDTO) async throws -> AuthResponseDTO {
        try await authRepository.signUp(request: request)
    }
}
