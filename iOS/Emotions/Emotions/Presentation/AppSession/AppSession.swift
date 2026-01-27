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

    private let container: AppContainer
    private let tokenManager: TokenManagerProtocol

    init(container: AppContainer, tokenManager: TokenManagerProtocol) {
        self.container = container
        self.tokenManager = tokenManager
    }

    func bootstrap() async {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if !hasCompletedOnboarding {
            route = .onboarding
            return
        }

        if await tokenManager.ensureToken() != nil {
            route = .main
            return
        }

        if let (username, password) = try? container.keychainStore.getCredentials() {
            do {
                _ = try await container.authUseCase.signIn(request: SignInRequestDTO(username: username, password: password))
                route = .main
                return
            } catch {
                route = .auth(mode: .signIn)
                return
            }
        }
        route = .auth(mode: .signUp)
    }

    func onOnboardingFinished() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        route = .auth(mode: .signUp)
    }

    func onAuthSuccess() {
        route = .main
    }

    func logout() async {
        await tokenManager.clearCredentials()
        route = .auth(mode: .signIn)
    }
}