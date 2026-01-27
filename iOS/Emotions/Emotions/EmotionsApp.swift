import SwiftUI

@main
struct EmotionsApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .environment(\.container, container)
        }
    }
}
