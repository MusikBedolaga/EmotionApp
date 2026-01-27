import Foundation

actor ContentMockStore {
    static let shared = ContentMockStore()

    private var albums: [Album]
    private var notes: [Note]
    private var topics: [Topic]

    private var nextAlbumId: Int64
    private var nextNoteId: Int64
    private var nextTopicId: Int64

    init(seed: Bool = true) {
        if seed {
            let now = Date()

            self.topics = [
                Topic(id: 1, name: "Работа", colorHex: "#3B82F6", createdAt: now),
                Topic(id: 2, name: "Личное", colorHex: "#EC4899", createdAt: now),
                Topic(id: 3, name: "Идеи", colorHex: "#22C55E", createdAt: now)
            ]

            self.albums = [
                Album(id: 1, userId: 1, title: "Входящие", description: "Быстрые заметки", createdAt: now),
                Album(id: 2, userId: 1, title: "Проекты", description: nil, createdAt: now)
            ]

            self.notes = [
                Note(id: 1, albumId: 1, title: "Добро пожаловать", content: "Это тестовая заметка.", createdAt: now, topicId: 2),
                Note(id: 2, albumId: 1, title: "Список дел", content: "1) ...\n2) ...", createdAt: now, topicId: nil),
                Note(id: 3, albumId: 2, title: "Идея", content: "Набросок будущей фичи.", createdAt: now, topicId: 3)
            ]
        } else {
            self.topics = []
            self.albums = []
            self.notes = []
        }

        self.nextAlbumId = (albums.map(\.id).max() ?? 0) + 1
        self.nextNoteId = (notes.map(\.id).max() ?? 0) + 1
        self.nextTopicId = (topics.map(\.id).max() ?? 0) + 1
    }

    // MARK: - Albums

    func fetchAlbums(userId: Int64) -> [Album] {
        albums
            .filter { $0.userId == userId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func createAlbum(userId: Int64, title: String, description: String?) -> Album {
        let album = Album(
            id: nextAlbumId,
            userId: userId,
            title: title,
            description: description,
            createdAt: Date()
        )
        nextAlbumId += 1
        albums.append(album)
        return album
    }

    func ensureAlbum(userId: Int64, albumId: Int64, fallbackTitle: String) -> Album {
        if let existing = albums.first(where: { $0.id == albumId && $0.userId == userId }) {
            return existing
        }

        let album = Album(
            id: albumId,
            userId: userId,
            title: fallbackTitle,
            description: nil,
            createdAt: Date()
        )
        albums.append(album)
        nextAlbumId = max(nextAlbumId, albumId + 1)
        return album
    }

    func ensureAnyAlbum(userId: Int64) -> Album {
        if let first = albums.first(where: { $0.userId == userId }) {
            return first
        }
        return createAlbum(userId: userId, title: "Входящие", description: nil)
    }

    // MARK: - Notes

    func fetchNotes(userId: Int64, albumId: Int64) -> [Note] {
        guard albums.contains(where: { $0.id == albumId && $0.userId == userId }) else {
            return []
        }

        return notes
            .filter { $0.albumId == albumId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func fetchNote(userId: Int64, id: Int64) -> Note {
        if let existing = notes.first(where: { $0.id == id }) {
            if albums.contains(where: { $0.id == existing.albumId && $0.userId == userId }) {
                return existing
            }
        }

        // Без ошибок по умолчанию: если заметка не найдена, создаём "плейсхолдер" для пользователя.
        let album = ensureAnyAlbum(userId: userId)
        return ensureNote(
            userId: userId,
            id: id,
            albumId: album.id,
            title: "Заметка \(id)",
            content: "",
            topicId: nil
        )
    }

    func createNote(
        userId: Int64,
        albumId: Int64,
        title: String,
        content: String,
        topicId: Int64?
    ) -> Note {
        _ = ensureAlbum(userId: userId, albumId: albumId, fallbackTitle: "Альбом \(albumId)")

        let note = Note(
            id: nextNoteId,
            albumId: albumId,
            title: title,
            content: content,
            createdAt: Date(),
            topicId: topicId
        )
        nextNoteId += 1
        notes.append(note)
        return note
    }

    private func ensureNote(
        userId: Int64,
        id: Int64,
        albumId: Int64,
        title: String,
        content: String,
        topicId: Int64?
    ) -> Note {
        _ = ensureAlbum(userId: userId, albumId: albumId, fallbackTitle: "Альбом \(albumId)")

        if let existing = notes.first(where: { $0.id == id }) {
            return existing
        }

        let note = Note(
            id: id,
            albumId: albumId,
            title: title,
            content: content,
            createdAt: Date(),
            topicId: topicId
        )
        notes.append(note)
        nextNoteId = max(nextNoteId, id + 1)
        return note
    }

    // MARK: - Topics

    func fetchTopics() -> [Topic] {
        topics
            .sorted { $0.createdAt > $1.createdAt }
    }
}
