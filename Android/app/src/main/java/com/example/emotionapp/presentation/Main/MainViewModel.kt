package com.example.emotionapp.presentation.Main

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.emotionapp.domain.entities.Album
import com.example.emotionapp.domain.entities.Topic
import com.example.emotionapp.domain.repository.AlbumRepository
import com.example.emotionapp.domain.repository.TopicRepository
import com.example.emotionapp.utils.NetworkResult
import com.example.emotionapp.utils.asErrorText
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class MainUiState(
    val searchText: String = "",
    val isLoading: Boolean = false,
    val errorText: String? = null,
    val topics: List<Topic> = emptyList(),
    val albums: List<Album> = emptyList(),
    val selectedTopicId: Long? = null
)

sealed interface MainUiEvent {
    data class ShowMessage(val text: String): MainUiEvent
    data object NavigateToCreateAlbum: MainUiEvent
    data class NavigateToAlbumDetails(val albumId: Long, val title: String): MainUiEvent
    data object NavigateToAnalyticsAi: MainUiEvent
}

class MainViewModel @Inject constructor(
    private val albumRepository: AlbumRepository,
    private val topicRepository: TopicRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(MainUiState())
    val uiState: StateFlow<MainUiState> = _uiState.asStateFlow()

    private val _events = Channel<MainUiEvent>(Channel.BUFFERED)
    val events: Flow<MainUiEvent> = _events.receiveAsFlow()

    val filteredAlbums: StateFlow<List<Album>> =
        uiState
            .map { s ->
                val query = s.searchText.trim()
                val selected = s.selectedTopicId

                s.albums
                    .asSequence()
                    .filter { album ->
                        query.isBlank() || album.title.contains(query, ignoreCase = true)
                    }
                    .filter { album ->
                        selected == null || album.topics.any { it.id == selected }
                    }
                    .toList()
            }
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5_000),
                initialValue = emptyList()
            )

    fun onAppear() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorText = null) }

            val albumsResult = albumRepository.getAllAlbums()
            val topicResult = topicRepository.getAllTopics()

            // TODO: Заменить на корутин структур
            val albums: List<Album>? = when (albumsResult) {
                is NetworkResult.Ok -> albumsResult.data
                is NetworkResult.Error.Http -> null
                is NetworkResult.Error.Network -> null
                is NetworkResult.Error.Unknown -> null
            }

            val topics: List<Topic>? = when (topicResult) {
                is NetworkResult.Ok -> topicResult.data
                is NetworkResult.Error.Http -> null
                is NetworkResult.Error.Network -> null
                is NetworkResult.Error.Unknown -> null
            }

            if (albums != null) _uiState.update { it.copy(albums = albums) }
            if (topics != null) _uiState.update { it.copy(topics = topics) }

            val errorText = buildErrorText(albumsResult, topicResult)
            if (errorText != null) {
                _uiState.update { it.copy(errorText = errorText) }
                _events.send(MainUiEvent.ShowMessage(errorText))
            }

            _uiState.update { it.copy(isLoading = false) }
        }
    }

    fun openAnalytics() = viewModelScope.launch {
        _events.send(MainUiEvent.NavigateToAnalyticsAi)
    }

    fun onFilterTextChange(value: String) = _uiState.update { it.copy(searchText = value) }

    fun onSelectTopic(topicId: Long?) = _uiState.update { it.copy(selectedTopicId = topicId) }

    fun onCreateNewAlbum() = viewModelScope.launch {
        _events.send(MainUiEvent.NavigateToCreateAlbum)
    }

    fun openNoteScreen(albumId: Long, title: String) = viewModelScope.launch {
        _events.send(MainUiEvent.NavigateToAlbumDetails(albumId, title))
    }

    private fun buildErrorText(
        albumsRes: NetworkResult<List<Album>>,
        topicsRes: NetworkResult<List<Topic>>
    ): String? {
        val aErr = albumsRes.asErrorText("альбомы")
        val tErr = topicsRes.asErrorText("топики")
        return when {
            aErr != null && tErr != null -> "$aErr\n$tErr"
            aErr != null -> aErr
            tErr != null -> tErr
            else -> null
        }
    }
}
