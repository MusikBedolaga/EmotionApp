package com.example.emotionapp.presentation.NoteDetails

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.emotionapp.domain.entities.Note
import com.example.emotionapp.domain.repository.NoteRepository
import com.example.emotionapp.utils.NetworkResult
import com.example.emotionapp.utils.asErrorText
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class NoteDetailsUiState(
    val note: Note? = null,

    val title: String = "",
    val content: String = "",

    val isLoading: Boolean = false,
    val isSaving: Boolean = false,
    val isDeleting: Boolean = false,

    val errorMessage: String? = null
)

sealed interface NoteDetailsUiEvents {
    data object NavigateGoBack : NoteDetailsUiEvents
    data object Saved : NoteDetailsUiEvents
    data object Deleted : NoteDetailsUiEvents
}

class NoteDetailsViewModel @Inject constructor(
    private val noteRepository: NoteRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(NoteDetailsUiState())
    val uiState: StateFlow<NoteDetailsUiState> = _uiState.asStateFlow()

    private val _events = Channel<NoteDetailsUiEvents>(Channel.BUFFERED)
    val events: Flow<NoteDetailsUiEvents> = _events.receiveAsFlow()

    fun onAppear(noteId: Long) = viewModelScope.launch {
        _uiState.update { it.copy(isLoading = true, errorMessage = null) }

        val res = noteRepository.getNote(noteId)

        when (res) {
            is NetworkResult.Ok -> {
                val note = res.data
                _uiState.update {
                    it.copy(
                        note = note,
                        title = note.title,
                        content = note.content,
                        isLoading = false,
                        errorMessage = null
                    )
                }
            }
            is NetworkResult.Error -> {
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        errorMessage = res.asErrorText("заметку")
                    )
                }
            }
        }
    }

    fun onChangeTitle(value: String) {
        _uiState.update { it.copy(title = value) }
    }

    fun onChangeContent(value: String) {
        _uiState.update { it.copy(content = value) }
    }

    fun onSaveClicked() = viewModelScope.launch {
        val current = _uiState.value.note ?: return@launch

        _uiState.update { it.copy(isSaving = true, errorMessage = null) }
        try {
            val updated = current.copy(
                title = _uiState.value.title,
                content = _uiState.value.content
            )

            // TODO: когда будет метод на бэке:
            // noteRepository.updateNote(updated)

            _uiState.update { it.copy(note = updated) }

            _events.send(NoteDetailsUiEvents.Saved)
            _events.send(NoteDetailsUiEvents.NavigateGoBack)
        } catch (t: Throwable) {
            _uiState.update { it.copy(errorMessage = t.message ?: "Ошибка сохранения") }
        } finally {
            _uiState.update { it.copy(isSaving = false) }
        }
    }

    fun onDeleteClicked() = viewModelScope.launch {
        val noteId = _uiState.value.note?.id ?: return@launch

        _uiState.update { it.copy(isDeleting = true, errorMessage = null) }

        val res = noteRepository.deleteNote(noteId)

        when (res) {
            is NetworkResult.Ok -> {
                _events.send(NoteDetailsUiEvents.Deleted)
                _events.send(NoteDetailsUiEvents.NavigateGoBack)
            }
            is NetworkResult.Error -> {
                // тут лучше не "при загрузке", поэтому руками:
                val text = when (res) {
                    is NetworkResult.Error.Http -> "Ошибка HTTP (${res.code}) при удалении заметки"
                    is NetworkResult.Error.Network -> "Ошибка сети при удалении заметки"
                    is NetworkResult.Error.Unknown -> "Неизвестная ошибка при удалении заметки"
                }
                _uiState.update { it.copy(errorMessage = text) }
            }
        }

        _uiState.update { it.copy(isDeleting = false) }
    }

    fun navigateGoBack() = viewModelScope.launch {
        _events.send(NoteDetailsUiEvents.NavigateGoBack)
    }

    fun clearError() {
        _uiState.update { it.copy(errorMessage = null) }
    }
}
