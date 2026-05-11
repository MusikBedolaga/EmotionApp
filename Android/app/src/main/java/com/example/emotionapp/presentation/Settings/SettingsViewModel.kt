package com.example.emotionapp.presentation.Settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.emotionapp.data.network.TokenStorage
import com.example.emotionapp.domain.repository.UserPreferencesRepository
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

enum class SettingsThemeOption(val value: String, val title: String) {
    LIGHT(value = "light", title = "Светлая"),
    DARK(value = "dark", title = "Тёмная");

    companion object {
        fun fromValue(value: String): SettingsThemeOption =
            entries.firstOrNull { it.value == value } ?: LIGHT
    }
}

data class SettingsUiState(
    val username: String = "Пользователь",
    val email: String = "Не указан",
    val notificationsEnabled: Boolean = true,
    val selectedTheme: SettingsThemeOption = SettingsThemeOption.LIGHT,
    val isLoggingOut: Boolean = false
) {
    val avatarText: String
        get() {
            val source = username.ifBlank { email }
            val first = source.firstOrNull { it.isLetterOrDigit() } ?: return "?"
            return first.uppercase()
        }
}

sealed interface SettingsUiEvent {
    data object LogoutCompleted : SettingsUiEvent
}

class SettingsViewModel @Inject constructor(
    private val preferencesRepository: UserPreferencesRepository,
    private val tokenStorage: TokenStorage
) : ViewModel() {

    private val isLoggingOut = kotlinx.coroutines.flow.MutableStateFlow(false)
    private val _events = Channel<SettingsUiEvent>(Channel.BUFFERED)
    val events: Flow<SettingsUiEvent> = _events.receiveAsFlow()

    val uiState: StateFlow<SettingsUiState> =
        combine(
            preferencesRepository.username,
            preferencesRepository.email,
            preferencesRepository.notificationsEnabled,
            preferencesRepository.selectedTheme,
            isLoggingOut
        ) { username, email, notificationsEnabled, selectedTheme, loggingOut ->
            SettingsUiState(
                username = username.ifBlank { "Пользователь" },
                email = email.ifBlank { "Не указан" },
                notificationsEnabled = notificationsEnabled,
                selectedTheme = SettingsThemeOption.fromValue(selectedTheme),
                isLoggingOut = loggingOut
            )
        }.stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5_000),
            initialValue = SettingsUiState()
        )

    fun onNotificationsChanged(enabled: Boolean) {
        viewModelScope.launch {
            preferencesRepository.setNotificationsEnabled(enabled)
        }
    }

    fun onThemeSelected(theme: SettingsThemeOption) {
        viewModelScope.launch {
            preferencesRepository.setSelectedTheme(theme.value)
        }
    }

    fun logout() {
        viewModelScope.launch {
            isLoggingOut.value = true
            preferencesRepository.clearSession()
            tokenStorage.clear()
            _events.send(SettingsUiEvent.LogoutCompleted)
            isLoggingOut.value = false
        }
    }
}
