import SwiftUI

struct MainTabView: View {
    @SwiftUI.Environment(\.container)
    private var container: AppContainer

    @EnvironmentObject
    private var session: AppSession

    let userId: Int64

    var body: some View {
        let albumsRepo = container.makeAlbumsRepository()
        let notesRepo = container.makeNotesRepository()
        let topicsRepo = container.makeTopicsRepository()

        TabView {
            NavigationStack {
                ContentRootView(
                    userId: userId,
                    albumsRepo: albumsRepo,
                    notesRepo: notesRepo,
                    topicsRepo: topicsRepo
                )
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                CreateNoteView(
                    userId: userId,
                    albumId: 1,
                    albumTitle: "Входящие",
                    notesRepo: notesRepo,
                    albumsRepo: albumsRepo,
                    topicsRepo: topicsRepo
                )
            }
            .tabItem {
                Label("Создать", systemImage: "pencil")
            }

            NavigationStack {
                SettingsView(
                    session: session,
                    tokenManager: container.tokenManager
                )
            }
            .tabItem {
                Label("Профиль", systemImage: "person")
            }
        }
    }
}

