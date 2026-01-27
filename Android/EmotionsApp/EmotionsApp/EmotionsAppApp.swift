//
//  EmotionsAppApp.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

import SwiftUI
import SwiftData

@main
struct EmotionsAppApp: App {
    let authService: any AuthService
    let albumService: any AlbumService
    let noteService: any NoteService
    
    init() {
        let secureStore = KeychainStore()
        let client = AuthClient(baseURL: Bundle.main.serverBaseURL)
        self.authService = AuthServiceImpl(client: client, secureStore: secureStore)
        let clientAlbum = AlbumClient(baseURL: URL(string: "http://localhost:50245")!, secureStore: secureStore)
        let clientNote = NoteClient(baseURL: URL(string: "http://localhost:50245")!, secureStore: secureStore)
        self.albumService = AlbumServiceImpl(client: clientAlbum)
        self.noteService = NotServerImpl(client: clientNote)
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
//            RegisterView(authService: authService)
//            AlbumListView(albumService: albumService)
            NoteListView(album: Album(id: 52, title: "Альбом1", description: "Описание альбома1"), noteService: noteService)
        }
        .modelContainer(sharedModelContainer)
    }
}
