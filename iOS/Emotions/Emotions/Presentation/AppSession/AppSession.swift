import Foundation
import SwiftUI

enum AppRoute: Equatable {
    enum AuthMode: Equatable {
        case signIn
        case signUp
    }

    case onboarding
    case auth(mode: AuthMode)
    case main
}

@MainActor
final class AppSession: ObservableObject {
    @Published
    var route: AppRoute = .onboarding

    @Published
    private(set) var currentUser: SessionUser?

    private let container: AppContainer
    private let tokenManager: TokenManagerProtocol

    init(container: AppContainer, tokenManager: TokenManagerProtocol) {
        self.container = container
        self.tokenManager = tokenManager
    }

    func bootstrap() async {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if !hasCompletedOnboarding {
            currentUser = nil
            route = .onboarding
            return
        }

        if let token = await tokenManager.ensureToken() {
            currentUser = SessionUser(token: token)
            route = .main
            return
        }

        if let (username, password) = try? container.keychainStore.getCredentials() {
            do {
                let authResponse = try await container.authUseCase.signIn(
                    request: SignInRequestDTO(username: username, password: password)
                )
                await completeAuthentication(
                    with: AuthSessionContext(
                        token: authResponse.token,
                        credentialIdentifier: username,
                        password: password,
                        fallbackUsername: username.contains("@") ? nil : username,
                        fallbackEmail: username.contains("@") ? username : nil
                    )
                )
                return
            } catch {
                currentUser = nil
                route = .auth(mode: .signIn)
                return
            }
        }
        currentUser = nil
        route = .auth(mode: .signUp)
    }

    func onOnboardingFinished() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        route = .auth(mode: .signUp)
    }

    func completeAuthentication(with context: AuthSessionContext) async {
        try? container.keychainStore.save(
            username: context.credentialIdentifier,
            password: context.password
        )
        await tokenManager.save(token: context.token)
        currentUser = SessionUser(
            token: context.token,
            fallbackUsername: context.fallbackUsername,
            fallbackEmail: context.fallbackEmail
        )
        route = .main
    }

    func logout() async {
        currentUser = nil
        await tokenManager.clearCredentials()
        route = .auth(mode: .signIn)
    }
}

struct SessionUser: Equatable {
    let id: Int64?
    let username: String
    let email: String?

    static let placeholder = SessionUser(id: nil, username: "Пользователь", email: nil)

    init(id: Int64?, username: String, email: String?) {
        self.id = id
        self.username = username
        self.email = email
    }

    init(token: String, fallbackUsername: String? = nil, fallbackEmail: String? = nil) {
        let claims = Self.decodeClaims(from: token)
        let resolvedEmail = claims?.email?.trimmedNonEmpty ?? fallbackEmail?.trimmedNonEmpty
        let resolvedUsername =
            claims?.username?.trimmedNonEmpty
            ?? claims?.sub?.trimmedNonEmpty
            ?? fallbackUsername?.trimmedNonEmpty
            ?? resolvedEmail
            ?? "Пользователь"

        self.id = claims?.id
        self.username = resolvedUsername
        self.email = resolvedEmail
    }

    var displayName: String {
        username
    }

    var secondaryText: String {
        email ?? "Авторизованный пользователь"
    }

    var emailText: String {
        email ?? "Не указан"
    }

    var idText: String {
        id.map(String.init) ?? "Не указан"
    }

    var initials: String {
        let parts = displayName
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .prefix(2)
        let letters = parts.compactMap(\.first)

        if !letters.isEmpty {
            return String(letters).uppercased()
        }

        guard let first = displayName.first else {
            return ""
        }

        return String(first).uppercased()
    }
}

private struct SessionUserClaims: Decodable {
    let id: Int64?
    let username: String?
    let email: String?
    let sub: String?
}

private extension SessionUser {
    static func decodeClaims(from token: String) -> SessionUserClaims? {
        let segments = token.split(separator: ".")
        guard segments.count > 1 else {
            return nil
        }

        var payload = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let remainder = payload.count % 4
        if remainder != 0 {
            payload += String(repeating: "=", count: 4 - remainder)
        }

        guard let data = Data(base64Encoded: payload) else {
            return nil
        }

        return try? JSONDecoder().decode(SessionUserClaims.self, from: data)
    }
}

private extension String {
    var trimmedNonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}