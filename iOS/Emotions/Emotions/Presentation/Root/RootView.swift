import SwiftUI

struct RootView: View {
    @StateObject
    private var session: AppSession

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
        _session = StateObject(wrappedValue: container.makeAppSession())
    }

    var body: some View {
        Group {
            switch session.route {
            case .onboarding:
                OnboardingView()
            case .auth(let mode):
                AuthView(
                    viewModel: container.makeAuthViewModel(),
                    initialAuthMode: mode
                )
            case .main:
                if let userId = session.currentUser?.id {
                    MainTabView(userId: userId)
                } else {
                    missingSessionView
                }
            }
        }
        .task {
            await session.bootstrap()
        }
        .environmentObject(session)
    }

    private var missingSessionView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Восстанавливаем данные пользователя")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}