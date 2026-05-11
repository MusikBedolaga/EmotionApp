package com.example.emotionapp.presentation.CreateNote

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.emotionapp.domain.repository.NoteRepository
import com.example.emotionapp.utils.NetworkResult
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class CreateNoteUiState(
    val title: String = "",
    val content: String = "",
    val isSaving: Boolean = false,
    val errorText: String? = null
)

sealed interface CreateNoteUiEvent {
    data class ShowMessage(val text: String) : CreateNoteUiEvent
    data object NoteCreated : CreateNoteUiEvent
}

class CreateNoteViewModel @Inject constructor(
    private val noteRepository: NoteRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(CreateNoteUiState())
    val uiState: StateFlow<CreateNoteUiState> = _uiState.asStateFlow()

    private val _events = Channel<CreateNoteUiEvent>(Channel.BUFFERED)
    val events: Flow<CreateNoteUiEvent> = _events.receiveAsFlow()

    fun onTitleChange(value: String) {
        _uiState.update { it.copy(title = value, errorText = null) }
    }

    fun onContentChange(value: String) {
        _uiState.update { it.copy(content = value, errorText = null) }
    }

    fun save(albumId: Long) {
        val state = _uiState.value
        if (state.title.isBlank()) {
            _uiState.update { it.copy(errorText = "Введите название заметки") }
            return
        }
        if (state.content.isBlank()) {
            _uiState.update { it.copy(errorText = "Введите текст заметки") }
            return
        }

        viewModelScope.launch {
            _uiState.update { it.copy(isSaving = true, errorText = null) }

            when (noteRepository.createNote(albumId, state.title.trim(), state.content.trim())) {
                is NetworkResult.Ok -> {
                    _events.send(CreateNoteUiEvent.ShowMessage("Заметка создана"))
                    _events.send(CreateNoteUiEvent.NoteCreated)
                    _uiState.value = CreateNoteUiState()
                }

                is NetworkResult.Error.Http -> {
                    _uiState.update { it.copy(errorText = "Ошибка HTTP при создании заметки") }
                }

                is NetworkResult.Error.Network -> {
                    _uiState.update { it.copy(errorText = "Ошибка сети при создании заметки") }
                }

                is NetworkResult.Error.Unknown -> {
                    _uiState.update { it.copy(errorText = "Неизвестная ошибка при создании заметки") }
                }
            }

            _uiState.update { it.copy(isSaving = false) }
        }
    }
}
