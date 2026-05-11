package com.example.emotionapp.presentation.CreateAlbum

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.emotionapp.domain.repository.AlbumRepository
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

data class CreateAlbumUiState(
    val title: String = "",
    val description: String = "",
    val isSaving: Boolean = false,
    val errorText: String? = null
)

sealed interface CreateAlbumUiEvent {
    data class ShowMessage(val text: String) : CreateAlbumUiEvent
    data object AlbumCreated : CreateAlbumUiEvent
}

class CreateAlbumViewModel @Inject constructor(
    private val albumRepository: AlbumRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(CreateAlbumUiState())
    val uiState: StateFlow<CreateAlbumUiState> = _uiState.asStateFlow()

    private val _events = Channel<CreateAlbumUiEvent>(Channel.BUFFERED)
    val events: Flow<CreateAlbumUiEvent> = _events.receiveAsFlow()

    fun onTitleChange(value: String) {
        _uiState.update { it.copy(title = value, errorText = null) }
    }

    fun onDescriptionChange(value: String) {
        _uiState.update { it.copy(description = value, errorText = null) }
    }

    fun save() {
        val state = _uiState.value
        if (state.title.isBlank()) {
            _uiState.update { it.copy(errorText = "Введите название альбома") }
            return
        }

        viewModelScope.launch {
            _uiState.update { it.copy(isSaving = true, errorText = null) }

            when (albumRepository.createAlbum(state.title.trim(), state.description.trim())) {
                is NetworkResult.Ok -> {
                    _events.send(CreateAlbumUiEvent.ShowMessage("Альбом создан"))
                    _events.send(CreateAlbumUiEvent.AlbumCreated)
                    _uiState.value = CreateAlbumUiState()
                }

                is NetworkResult.Error.Http -> {
                    _uiState.update { it.copy(errorText = "Ошибка HTTP при создании альбома") }
                }

                is NetworkResult.Error.Network -> {
                    _uiState.update { it.copy(errorText = "Ошибка сети при создании альбома") }
                }

                is NetworkResult.Error.Unknown -> {
                    _uiState.update { it.copy(errorText = "Неизвестная ошибка при создании альбома") }
                }
            }

            _uiState.update { it.copy(isSaving = false) }
        }
    }
}
