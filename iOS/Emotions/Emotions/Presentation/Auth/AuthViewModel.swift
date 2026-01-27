import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {

    @Published 
    var email = ""
    
    @Published 
    var password = ""
    
    @Published 
    var name = ""

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published
     var isRegistering = false

    @Published
    var shouldShakeEmail = false

    @Published
    var shouldShakePassword = false

    @Published 
    var shouldShakeName = false

    private let authUseCase: AuthUseCaseProtocol

    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
    }
}

extension AuthViewModel {
    func signIn() async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard validateUsername() else {
            animateShake(\.shouldShakeEmail)
            return false
        }

        guard validatePassword() else {
            animateShake(\.shouldShakePassword)
            return false
        }

        do {
            let usernameOrEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let request = SignInRequestDTO(username: usernameOrEmail, password: password)
            _ = try await authUseCase.signIn(request: request)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func signUp() async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard validateName() else {
            animateShake(\.shouldShakeName)
            return false
        }

        guard validateEmail() else {
            animateShake(\.shouldShakeEmail)
            return false
        }

        guard validatePassword() else {
            animateShake(\.shouldShakePassword)
            return false
        }

        do {
            let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

            let request = SignUpRequestDTO(
                username: cleanName,
                email: cleanEmail,
                password: password
            )
            _ = try await authUseCase.signUp(request: request)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

// MARK: - Helpers
private extension AuthViewModel {

    func animateShake(_ keyPath: ReferenceWritableKeyPath<AuthViewModel, Bool>) {
        self[keyPath: keyPath] = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self[keyPath: keyPath] = false
        }
    }

    func validateUsername() -> Bool {
        email.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    func validateEmail() -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func validatePassword() -> Bool {
        password.count >= 6
    }

    func validateName() -> Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }
}

extension AuthViewModel {
    var friendlyError: String {
        guard let msg = errorMessage else { return "" }
        let lower = msg.lowercased()

        if lower.contains("network") || lower.contains("internet") {
            return "Нет подключения к интернету. Попробуйте позже."
        }
        if lower.contains("401") || lower.contains("invalid credentials") {
            return "Неверный логин или пароль."
        }
        if (lower.contains("user") && lower.contains("exists")) || lower.contains("already exists") {
            return "Пользователь уже существует."
        }
        return msg
    }
}
