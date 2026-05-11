import SwiftUI

enum SettingsTheme: String, CaseIterable, Identifiable {
    case light
    case dark

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .light:
            return "Светлая"
        case .dark:
            return "Тёмная"
        }
    }
}

@MainActor
final class SettingsViewModel: ObservableObject {
    private enum Keys {
        static let notificationsEnabled = "notifications_enabled"
        static let selectedTheme = "settings_selected_theme"
    }

    @Published
    var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }

    @Published
    var selectedTheme: SettingsTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: Keys.selectedTheme)
        }
    }

    @Published
    private(set) var user: SessionUser

    private let session: AppSession

    init(session: AppSession) {
        self.session = session

        let defaults = UserDefaults.standard
        if defaults.object(forKey: Keys.notificationsEnabled) == nil {
            defaults.set(true, forKey: Keys.notificationsEnabled)
        }

        let storedTheme = defaults.string(forKey: Keys.selectedTheme)
        let selectedTheme = SettingsTheme(rawValue: storedTheme ?? "") ?? .light

        self.notificationsEnabled = defaults.bool(forKey: Keys.notificationsEnabled)
        self.selectedTheme = selectedTheme
        self.user = session.currentUser ?? .placeholder
    }

    func logout() async {
        await session.logout()
    }
}

