package com.example.emotionapp.navigation

sealed class Route(val route: String) {

    data object Onboarding : Route("onboarding")
    data object Auth : Route("auth")
    data object Main : Route("main")

    data object Home : Route("home")
    data object Create : Route("create")
    data object Profile : Route("profile")

    data object AlbumDetails: Route("album/{id}?title={title}") {
        const val idArg = "id"
        const val titleArg = "title"
        fun createRoute(id: Long, title: String): String {
            val encodedTitle = android.net.Uri.encode(title)
            return "album/$id?title=$encodedTitle"
        }
    }
    data object Analytics : Route("analytics")
    data object CreateAlbum : Route("create_album")
    data object NoteDetails : Route("note/{id}") {
        const val idArg = "id"
        fun createRoute(id: Long): String = "note/$id"
    }
    data object CreateNote : Route("create_note?albumId={albumId}") {
        const val albumIdArg = "albumId"
        fun createRoute(albumId: Long): String = "create_note?albumId=$albumId"
    }
}
