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
                // TODO: временно используем userId = 1, пока userId не прокинут из auth/профиля.
                MainTabView(userId: 1)
            }
        }
        .task {
            await session.bootstrap()
        }
        .environmentObject(session)
    }
}