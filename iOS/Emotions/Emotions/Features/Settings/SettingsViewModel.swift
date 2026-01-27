import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    private enum Keys {
        static let notificationsEnabled = "notifications_enabled"
    }

    @Published
    var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }

    private let session: AppSession
    private let tokenManager: TokenManagerProtocol

    init(session: AppSession, tokenManager: TokenManagerProtocol) {
        self.session = session
        self.tokenManager = tokenManager

        let defaults = UserDefaults.standard
        if defaults.object(forKey: Keys.notificationsEnabled) == nil {
            defaults.set(true, forKey: Keys.notificationsEnabled)
        }
        self.notificationsEnabled = defaults.bool(forKey: Keys.notificationsEnabled)
    }

    func logout() async {
        if let bundleId = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleId)
            UserDefaults.standard.synchronize()
        }

        // Очищаем авторизацию (токены + креды) в Keychain через существующий TokenManager.
        await tokenManager.clearCredentials()

        // Триггерим переход на auth.
        session.route = .auth(mode: .signIn)
    }
}

