import Foundation

protocol AuthRepositoryProtocol {
    func signIn(request: SignInRequestDTO) async throws -> AuthResponseDTO
    func signUp(request: SignUpRequestDTO) async throws -> AuthResponseDTO
}
