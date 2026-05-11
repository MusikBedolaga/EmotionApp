import Foundation
import SwiftUI

struct AuthSessionContext: Sendable {
    let token: String
    let credentialIdentifier: String
    let password: String
    let fallbackUsername: String?
    let fallbackEmail: String?
}

@MainActor
final class AuthViewModel: ObservableObject {
    private enum AuthFlow {
        case signIn
        case signUp
    }

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
    func signIn() async -> AuthSessionContext? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard validateUsername() else {
            errorMessage = Validation.username
            animateShake(\.shouldShakeEmail)
            return nil
        }

        guard validatePassword() else {
            errorMessage = Validation.password
            animateShake(\.shouldShakePassword)
            return nil
        }

        do {
            let usernameOrEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let request = SignInRequestDTO(username: usernameOrEmail, password: password)
            let authResponse = try await authUseCase.signIn(request: request)
            return AuthSessionContext(
                token: authResponse.token,
                credentialIdentifier: usernameOrEmail,
                password: password,
                fallbackUsername: usernameOrEmail.contains("@") ? nil : usernameOrEmail,
                fallbackEmail: usernameOrEmail.contains("@") ? usernameOrEmail : nil
            )
        } catch {
            errorMessage = friendlyMessage(for: error, flow: .signIn)
            return nil
        }
    }

    func signUp() async -> AuthSessionContext? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard validateName() else {
            errorMessage = Validation.username
            animateShake(\.shouldShakeName)
            return nil
        }

        guard validateEmail() else {
            errorMessage = Validation.email
            animateShake(\.shouldShakeEmail)
            return nil
        }

        guard validatePassword() else {
            errorMessage = Validation.password
            animateShake(\.shouldShakePassword)
            return nil
        }

        do {
            let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

            let request = SignUpRequestDTO(
                username: cleanName,
                email: cleanEmail,
                password: password
            )
            let authResponse = try await authUseCase.signUp(request: request)
            return AuthSessionContext(
                token: authResponse.token,
                credentialIdentifier: cleanName,
                password: password,
                fallbackUsername: cleanName,
                fallbackEmail: cleanEmail
            )
        } catch {
            errorMessage = friendlyMessage(for: error, flow: .signUp)
            return nil
        }
    }
}

// MARK: - Helpers
private extension AuthViewModel {
    enum Validation {
        static let username = "Имя пользователя должно содержать от 5 до 50 символов."
        static let email = "Введите корректный email."
        static let password = "Длина пароля должна быть от 8 до 255 символов."
    }

    func animateShake(_ keyPath: ReferenceWritableKeyPath<AuthViewModel, Bool>) {
        self[keyPath: keyPath] = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self[keyPath: keyPath] = false
        }
    }

    func validateUsername() -> Bool {
        let username = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return (5...50).contains(username.count)
    }

    func validateEmail() -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func validatePassword() -> Bool {
        (8...255).contains(password.count)
    }

    func validateName() -> Bool {
        let username = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return (5...50).contains(username.count)
    }

    private func friendlyMessage(for error: Error, flow: AuthFlow) -> String {
        if let networkError = error as? NetworkError {
            return friendlyMessage(for: networkError, flow: flow)
        }

        let nsError = error as NSError
        if isConnectivityError(nsError) {
            return "Нет подключения к интернету. Попробуйте позже."
        }

        return error.localizedDescription
    }

    private func friendlyMessage(for error: NetworkError, flow: AuthFlow) -> String {
        switch error {
        case .requestFailed(let statusCode, let data):
            if let backendMessage = backendMessage(from: data) {
                return backendMessage
            }

            switch statusCode {
            case 400:
                return flow == .signUp
                    ? "Проверьте имя пользователя, email и пароль."
                    : "Проверьте имя пользователя и пароль."
            case 401:
                return "Неверный логин или пароль."
            case 403:
                return flow == .signUp
                    ? "Не удалось зарегистрироваться. Проверьте имя пользователя и email. Возможно, пользователь уже существует."
                    : "Неверный логин или пароль."
            case 409:
                return "Пользователь уже существует."
            default:
                return "Ошибка сервера (\(statusCode)). Попробуйте позже."
            }

        case .unauthorized:
            return "Неверный логин или пароль."
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

    func backendMessage(from data: Data?) -> String? {
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

    func isConnectivityError(_ error: NSError) -> Bool {
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

extension AuthViewModel {
    var friendlyError: String {
        errorMessage ?? ""
    }
}
