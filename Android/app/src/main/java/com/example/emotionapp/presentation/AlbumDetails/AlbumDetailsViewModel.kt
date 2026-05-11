package com.example.emotionapp.presentation.AlbumDetails

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.emotionapp.domain.entities.NoteSummary
import com.example.emotionapp.domain.repository.NoteRepository
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

data class AlbumDetailsUiState(
    val searchText: String = "",
    val isLoading: Boolean = false,
    val errorText: String? = null,
    val notes: List<NoteSummary> = emptyList(),
    val selectedNoteId: Long? = null
)

sealed interface AlbumDetailsUiEvent {

    data class ShowMessage(val text: String): AlbumDetailsUiEvent
    data class NavigateToNote(val noteId: Long): AlbumDetailsUiEvent
    data object NavigateToCreateNote: AlbumDetailsUiEvent
    data object NavigateGoBack: AlbumDetailsUiEvent
}

class AlbumDetailsViewModel @Inject constructor(
    private val noteRepository: NoteRepository
): ViewModel() {

    private val _uiState = MutableStateFlow(AlbumDetailsUiState())
    val uiState: StateFlow<AlbumDetailsUiState> = _uiState.asStateFlow()

    private val _events = Channel<AlbumDetailsUiEvent>(Channel.BUFFERED)
    val events: Flow<AlbumDetailsUiEvent> = _events.receiveAsFlow()

    val filteredNotes: StateFlow<List<NoteSummary>> =
        uiState
            .map { search ->
                val query = search.searchText.trim()

                search.notes
                    .asSequence()
                    .filter { note ->
                        query.isBlank() || note.title.contains(query, ignoreCase = true)
                    }
                    .toList()
            }
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5_000),
                initialValue = emptyList()
            )

    fun onAppear(albumId: Long) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorText = null) }

            val noteResult = noteRepository.getNotesByAlbum(albumId = albumId)

            val notes: List<NoteSummary>? = when (noteResult) {
                is NetworkResult.Ok -> noteResult.data
                is NetworkResult.Error.Http -> null
                is NetworkResult.Error.Network -> null
                is NetworkResult.Error.Unknown -> null
            }

            if (notes != null) _uiState.update { it.copy(notes = notes) }

            val errorText = buildErrorText(noteResult)
            if (errorText != null) {
                _uiState.update { it.copy(errorText = errorText) }
                _events.send(AlbumDetailsUiEvent.ShowMessage(errorText))
            }

            _uiState.update { it.copy(isLoading = false) }
        }
    }

    fun openNote(noteId: Long) = viewModelScope.launch {
        _events.send(AlbumDetailsUiEvent.NavigateToNote(noteId = noteId))
    }

    fun onCreateNewNote() = viewModelScope.launch {
        _events.send(AlbumDetailsUiEvent.NavigateToCreateNote)
    }

    fun navigateGoBack() = viewModelScope.launch {
        _events.send(AlbumDetailsUiEvent.NavigateGoBack)
    }

    fun onChangeTextField(value: String) = _uiState.update { it.copy(searchText = value) }

    private fun buildErrorText(
        noteRes: NetworkResult<List<NoteSummary>>,
    ): String? {
        val nErr = noteRes.asErrorText("заметки")
        return when {
            nErr != null -> nErr
            else -> null
        }
    }
}
